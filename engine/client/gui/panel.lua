--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Panel class
--
--============================================================================--

require( "common.color" )
require( "engine.shared.tween" )

local accessor = accessor
local gui      = gui
local ipairs   = ipairs
local love     = love
local math     = math
local pairs    = pairs
local point    = point
local scheme   = scheme
local table    = table
local tween    = tween
local type     = type
local unpack   = unpack
local _G       = _G

local gui_draw_bounds = convar( "gui_draw_bounds", "0", nil, nil,
                                "Draws the bounds of panels for debugging" )

class( "gui.panel" )

maskedPanel = maskedPanel or nil

function drawMask()
	local self = gui.panel.maskedPanel
	love.graphics.rectangle( "fill", 0, 0, self:getWidth(), self:getHeight() )
end

function _M:panel( parent, name )
	self.x       = 0
	self.y       = 0
	self.width   = 0
	self.height  = 0
	self.name    = name or ""
	self:setParent( parent or _G.g_RootPanel )
	self.visible = true
	self.scale   = 1
	self.opacity = 1
end

local cos = math.cos
local pi  = math.pi

local easing = tween.easing

function _M:animate( properties, duration, easing, complete )
	if ( not self.animations ) then
		self.animations = {}
	end

	local step

	local options = duration
	if ( type( options ) == "table" ) then
		duration = options.duration
		easing   = options.easing
		step     = options.step
		complete = options.complete
	end

	local animation = {
		startTime = nil,
		tweens    = {},
		duration  = duration or 0.4,
		easing    = easing or "swing",
		step      = step,
		complete  = complete
	}

	for member, value in pairs( properties ) do
		animation.tweens[ member ] = {
			startValue = self[ member ],
			endValue   = value,
		}
	end
	table.insert( self.animations, animation )
end

function _M:createFramebuffer()
	local framebuffer = self.framebuffer
	if ( framebuffer and not self.needsRedraw ) then
		return
	end

	local width  = self:getWidth()
	local height = self:getHeight()
	if ( width == 0 or height == 0 ) then
		width  = nil
		height = nil
		if ( not self:shouldSuppressFramebufferWarnings() ) then
			local panel = tostring( self )
			print( "Attempt to create framebuffer for " .. panel ..
			       " with a size of 0!" )
		end
	end

	if ( not framebuffer ) then
		local fullscreen = self:shouldUseFullscreenFramebuffer()
		if ( fullscreen ) then
			self.framebuffer = love.graphics.newCanvas()
		else
			self.framebuffer = love.graphics.newCanvas( width, height )
		end
	end

	framebuffer = self.framebuffer
	-- if ( framebuffer:shouldAutoRedraw() ) then
	-- 	framebuffer:setAutoRedraw( false )
	-- end

	framebuffer:renderTo( function()
		self:draw()
	end )
	self.needsRedraw = nil
end

local opacityStack = { 1 }

function _M:draw()
	if ( not self:isVisible() ) then
		return
	end

	local children = self:getChildren()
	if ( children ) then
		for _, v in ipairs( children ) do
			v:createFramebuffer()
		end
	end

	if ( children ) then
		for _, v in ipairs( children ) do
			v:preDraw()
			v:drawFramebuffer()
			v:postDraw()
		end
	end
end

function _M:drawBackground( color )
	local width  = self:getWidth()
	local height = self:getHeight()
	love.graphics.setColor( unpack( self:getScheme( color ) ) )
	love.graphics.rectangle( "fill", 0, 0, width, height )
end

function _M:drawBounds()
	love.graphics.setColor( unpack( color.red ) )
	love.graphics.setLineWidth( point( 1 ) )
	love.graphics.rectangle( "line", 0, 0, self:getWidth(), self:getHeight() )
end

function _M:drawForeground( color )
	local width  = self:getWidth()
	local height = self:getHeight()
	love.graphics.setColor( unpack( self:getScheme( color ) ) )
	love.graphics.setLineWidth( point( 1 ) )
	love.graphics.rectangle( "line", 0, 0, width, height )
end

function _M:drawFramebuffer()
	if ( not self:isVisible() ) then
		return
	end

	if ( not self.framebuffer ) then
		self:createFramebuffer()
	end

	gui.panel.maskedPanel = self
	love.graphics.stencil( gui.panel.drawMask )
	love.graphics.setStencilTest( "greater", 0 )
		love.graphics.draw( self.framebuffer )
	love.graphics.setStencilTest()
end

local filtered = function( panel, func, ... )
	if ( not panel:isVisible() ) then
		return
	end

	return panel[ func ]( panel, ... )
end

local function cascadeInputToChildren( self, func, ... )
	if ( not self:isVisible() ) then
		return
	end

	local children = self:getChildren()
	if ( children ) then
		local value
		for _, v in ipairs( children ) do
			value = filtered( v, func, ... )
			if ( value ~= nil ) then
				return value
			end
		end
	end
end

function _M:filedropped( file )
	return cascadeInputToChildren( self, "filedropped", file )
end

accessor( _M, "children" )
accessor( _M, "name" )
accessor( _M, "opacity" )
accessor( _M, "parent" )
accessor( _M, "scale" )

local getProperty = scheme.getProperty

function _M:getScheme( property )
	return getProperty( self.scheme, property )
end

accessor( _M, "width" )
accessor( _M, "height" )

function _M:getSize()
	return self:getWidth(), self:getHeight()
end

accessor( _M, "x" )
accessor( _M, "y" )

function _M:getPos()
	return self:getX(), self:getY()
end

local sx, sy      = 0, 0
local w,  h       = 0, 0
local pointinrect = math.pointinrect
local children    = nil
local topChild    = nil

function _M:getTopMostChildAtPos( x, y )
	if ( not self:isVisible() ) then
		return nil
	end

	sx, sy = self:localToScreen()
	w,  h  = self:getWidth(), self:getHeight()
	if ( not pointinrect( x, y, sx, sy, w, h ) ) then
		return nil
	end

	children = self:getChildren()
	if ( children ) then
		for i = #children, 1, -1 do
			topChild = children[ i ]:getTopMostChildAtPos( x, y )
			if ( topChild ) then
				return topChild
			end
		end
	end

	return self
end

function _M:invalidate()
	self.needsRedraw = true

	local parent = self:getParent()
	while ( parent ~= nil ) do
		parent:invalidate()
		parent = parent:getParent()
	end
end

function _M:invalidateLayout()
	local children = self:getChildren()
	if ( children ) then
		for _, v in ipairs( children ) do
			v:invalidateLayout()
		end
	end

	self:invalidate()
end

function _M:invalidateParent()
	self:getParent():invalidate()
end

function _M:isChildMousedOver()
	local panel = gui.topPanel
	while ( panel ~= nil ) do
		panel = panel:getParent()
		if ( self == panel ) then
			return true
		end
	end

	return false
end

function _M:isTopMostChild()
	local children = self:getChildren()
	if ( children ) then
		return children[ #children ] == self
	else
		return true
	end
end

function _M:isVisible()
	return self.visible
end

function _M:joystickpressed( joystick, button )
	return cascadeInputToChildren( self, "joystickpressed", joystick, button )
end

function _M:joystickreleased( joystick, button )
	return cascadeInputToChildren( self, "joystickreleased", joystick, button )
end

function _M:keypressed( key, scancode, isrepeat )
	return cascadeInputToChildren( self, "keypressed", key, scancode, isrepeat )
end

function _M:keyreleased( key, scancode )
	return cascadeInputToChildren( self, "keyreleased", key, scancode )
end

local posX, posY = 0, 0
local parent     = nil

function _M:localToScreen( x, y )
	posX, posY = x or self:getX(), y or self:getY()
	parent     = self:getParent()
	while ( parent ~= nil ) do
		posX = posX + parent:getX()
		posY = posY + parent:getY()
		parent = parent:getParent()
	end

	return posX, posY
end

function _M:mousepressed( x, y, button, istouch )
	return cascadeInputToChildren( self, "mousepressed", x, y, button )
end

function _M:mousereleased( x, y, button, istouch )
	if ( not self:isVisible() ) then
		return
	end

	local children = self:getChildren()
	if ( children ) then
		for _, v in ipairs( children ) do
			v:mousereleased( x, y, button, istouch )
		end
	end
end

function _M:moveToFront()
	local parent   = self:getParent()
	local children = nil
	if ( parent ) then
		children = parent:getChildren()
		if ( self == children[ #children ] ) then
			return
		end
	end

	if ( gui.focusedPanel ) then
		gui.setFocusedPanel( nil, false )
	end

	if ( parent ) then
		for i, v in ipairs( children ) do
			if ( v == self ) then
				table.remove( children, i )
			end
		end

		children[ #children + 1 ] = self
	end

	if ( self:getParent() ) then
		self:invalidateParent()
	end
end

function _M:moveToBack()
	local parent   = self:getParent()
	local children = nil
	if ( parent ) then
		children = parent:getChildren()
		if ( self == children[ 1 ] ) then
			return
		end
	end

	if ( gui.focusedPanel ) then
		gui.setFocusedPanel( nil, false )
	end

	if ( parent ) then
		for i, v in ipairs( children ) do
			if ( v == self ) then
				table.remove( children, i )
			end
		end

		table.insert( children, 1, self )
	end

	if ( self:getParent() ) then
		self:invalidateParent()
	end
end

function _M:onMouseLeave()
end

function _M:onRemove()
end

local opacity = 1

function _M:preDraw()
	if ( not self:isVisible() ) then
		return
	end

	local scale  = self:getScale()
	local width  = self:getWidth()
	local height = self:getHeight()
	love.graphics.push()
	love.graphics.translate( self:getX(), self:getY() )
	love.graphics.scale( scale )
	love.graphics.translate(
		( width  / scale ) / 2 - width  / 2,
		( height / scale ) / 2 - height / 2
	)
	opacity = opacityStack[ #opacityStack ]
	opacity = opacity * self:getOpacity()
	-- graphics.setOpacity( opacity )
	table.insert( opacityStack, opacity )
end

function _M:postDraw()
	if ( not self:isVisible() ) then
		return
	end

	if ( gui_draw_bounds:getBoolean() ) then
		if ( self.mouseover ) then
			self:drawBounds()
		end
	end

	table.remove( opacityStack, #opacityStack )
	-- graphics.setOpacity( opacityStack[ #opacityStack ] )
	love.graphics.pop()
end

function _M:preDrawWorld()
	local children = self:getChildren()
	if ( children ) then
		for _, v in ipairs( children ) do
			v:preDrawWorld()
		end
	end
end

function _M:remove()
	if ( self:getChildren() ) then
		self:removeChildren()
	end

	if ( self:getParent() ) then
		local children = self:getParent():getChildren()
		for i, v in ipairs( children ) do
			if ( v == self ) then
				table.remove( children, i )
			end
		end

		if ( #children == 0 ) then
			self:getParent().children = nil
		end
	end

	self:onRemove()
end

function _M:removeChildren()
	local children = self:getChildren()
	if ( children ) then
		for i = #children, 1, -1 do
			children[ i ]:remove()
		end
	end
	self:invalidate()
end

local root = nil

function _M:screenToLocal( x, y )
	posX, posY = 0, 0
	root       = self
	while ( root:getParent() ~= nil ) do
		posX = posX + root:getX()
		posY = posY + root:getY()
		root = root:getParent()
	end

	x = x - posX
	y = y - posY

	return x, y
end

function _M:setUseFullscreenFramebuffer( useFullscreenFramebuffer )
	self.useFullscreenFramebuffer = useFullscreenFramebuffer and true or nil
end

function _M:setSuppressFramebufferWarnings( suppressFramebufferWarnings )
	self.suppressFramebufferWarnings = suppressFramebufferWarnings
end

function _M:setNextThink( nextThink )
	self.nextThink = nextThink
end

function _M:setOpacity( opacity )
	self.opacity = opacity
	self:invalidate()
end

function _M:setParent( panel )
	local parent = self:getParent()
	if ( parent ) then
		local children = parent:getChildren()
		for i, v in ipairs( children ) do
			if ( v == self ) then
				table.remove( children, i )
			end
		end
	end

	panel.children = panel.children or {}
	for _, v in ipairs( panel.children ) do
		if ( v == panel ) then
			return
		end
	end

	table.insert( panel.children, self )
	self.parent = panel
end

function _M:setScale( scale )
	self.scale = scale
	self:invalidate()
end

function _M:setScheme( name )
	if ( not scheme.isLoaded( name ) ) then
		scheme.load( name )
	end
	self.scheme = name
end

function _M:setVisible( visible )
	self.visible = visible
	self:invalidate()
end

function _M:setWidth( width )
	self.width = math.round( width )
	self:invalidate()
end

function _M:setHeight( height )
	self.height = math.round( height )
	self:invalidate()
end

function _M:setSize( width, height )
	self:setWidth( width )
	self:setHeight( height )
end

function _M:setX( x )
	self.x = math.round( x )
	if ( self:getParent() ) then
		self:invalidateParent()
	end
end

function _M:setY( y )
	self.y = math.round( y )
	if ( self:getParent() ) then
		self:invalidateParent()
	end
end

function _M:setPos( x, y )
	self:setX( x )
	self:setY( y )
end

function _M:shouldUseFullscreenFramebuffer()
	return self.useFullscreenFramebuffer
end

function _M:shouldSuppressFramebufferWarnings()
	return self.suppressFramebufferWarnings
end

function _M:textinput( text )
	return cascadeInputToChildren( self, "textinput", text )
end

function _M:textedited( text, start, length )
	return cascadeInputToChildren( self, "textedited", text, start, length )
end

function _M:update( dt )
	if ( self.think and
	     self.nextThink and
	     self.nextThink <= love.timer.getTime() ) then
		self.nextThink = nil
		self:think()
	end

	if ( self.animations ) then
		self:updateAnimations( dt )
	end

	local children = self:getChildren()
	if ( children ) then
		for _, v in ipairs( children ) do
			v:update( dt )
		end
	end
end

local startTime  = 0
local duration   = 0
local remaining  = 0
local max        = math.max
local percent    = 0
local startValue = 0
local endValue   = 0
local eased      = 0
local complete   = nil
local len        = table.len

function _M:updateAnimations( dt )
	for _, animation in ipairs( self.animations ) do
		if ( not animation.startTime ) then
			animation.startTime = love.timer.getTime()
		end

		startTime     = animation.startTime
		duration      = animation.duration
		remaining     = max( 0, startTime + duration - love.timer.getTime() )
		percent       = 1 - ( remaining / duration or 0 )
		animation.pos = percent

		for member, tween in pairs( animation.tweens ) do
			startValue = tween.startValue
			endValue   = tween.endValue
			eased      = easing[ animation.easing ](
				percent, duration * percent, 0, 1, duration
			)
			self[ member ] = ( endValue - startValue ) * eased + startValue

			if ( animation.step ) then
				animation.step( self[ member ], tween )
			end

			self:invalidate()
		end

		if ( percent == 1 ) then
			complete = animation.complete
			if ( complete ) then
				complete()
			end
			self:invalidate()
		end
	end

	for i = #self.animations, 1, -1 do
		if ( self.animations[ i ].pos and self.animations[ i ].pos == 1 ) then
			table.remove( self.animations, i )
		end
	end

	if ( len( self.animations ) == 0 ) then
		self.animations = nil
	end
end

function _M:wheelmoved( x, y )
	return cascadeInputToChildren( self, "wheelmoved", x, y )
end

function _M:__tostring()
	return "panel: \"" .. self.name .. "\" (" .. self.__type .. ")"
end
