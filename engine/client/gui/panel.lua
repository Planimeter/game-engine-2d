--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Panel class
--
--==========================================================================--

require( "common.color" )
require( "engine.shared.tween" )

class( "gui.panel" )

local panel = gui.panel

function panel.drawMask()
	local self = panel._maskedPanel
	love.graphics.rectangle( "fill", 0, 0, self:getSize() )
end

function panel:panel( parent, name )
	self.x       = 0
	self.y       = 0
	self.name    = name or ""
	self:setParent( parent or g_RootPanel )
	self.visible = true
	self.scale   = 1
	self.opacity = 1
end

function panel:animate( properties, duration, easing, complete )
	if ( self.animations == nil ) then
		self.animations = {}
	end

	local step = nil

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

function panel:createFramebuffer( width, height )
	if ( width == nil and height == nil ) then
		width, height = self:getSize()
	end

	if ( width == 0 or height == 0 ) then
		width, height = nil, nil
	end

	if ( self.framebuffer and not self.needsRedraw ) then
		return
	end

	if ( self.framebuffer == nil ) then
		require( "engine.client.canvas" )
		if ( self:shouldUseFullscreenFramebuffer() ) then
			self.framebuffer = fullscreencanvas()
		else
			self.framebuffer = canvas( width, height )
		end
	end

	if ( self.framebuffer:shouldAutoRedraw() ) then
		self.framebuffer:setAutoRedraw( false )
	end

	self.framebuffer:renderTo( function()
		love.graphics.clear()
		self:draw()
	end )

	self.needsRedraw = false
end

function panel:draw()
	if ( not self:isVisible() ) then
		return
	end

	local children = self:getChildren()
	if ( children == nil ) then
		return
	end

	for _, v in ipairs( children ) do
		v:createFramebuffer()
	end

	for _, v in ipairs( children ) do
		v:preDraw()
		v:drawFramebuffer()
		v:postDraw()
	end
end

function panel:drawBackground( color )
	local width, height = self:getSize()
	love.graphics.setColor( color )
	love.graphics.rectangle( "fill", 0, 0, width, height )
end

function panel:drawSelection()
	love.graphics.setColor( color.red )
	local lineWidth = 1
	love.graphics.setLineWidth( lineWidth )
	love.graphics.rectangle(
		"line",
		lineWidth / 2,
		lineWidth / 2,
		self:getWidth()  - lineWidth,
		self:getHeight() - lineWidth
	)
end

function panel:drawName()
	local font   = scheme.getProperty( "Default", "font" )
	love.graphics.setFont( font )
	local text   = self:getName()
	local width  = font:getWidth( text )
	local height = font:getHeight()
	love.graphics.setColor( color.red )
	love.graphics.rectangle( "fill", 0, 0, width + 6, height + 2 )

	love.graphics.setColor( color.white )
	love.graphics.print( text, 3, 1 )
end

function panel:drawBorder( color )
	love.graphics.setColor( color )
	local lineWidth = 1
	love.graphics.setLineWidth( lineWidth )
	love.graphics.rectangle(
		"line",
		lineWidth / 2,
		lineWidth / 2,
		self:getWidth()  - lineWidth,
		self:getHeight() - lineWidth
	)
end

function panel:drawFramebuffer()
	if ( not self:isVisible() ) then
		return
	end

	if ( self.framebuffer == nil ) then
		self:createFramebuffer()
	end

	love.graphics.push()
		local b = love.graphics.getBlendMode()
		love.graphics.setBlendMode( "alpha", "premultiplied" )
		local a = self:getOpacity()
		love.graphics.setColor( a, a, a, a )
		self.framebuffer:draw()
		love.graphics.setBlendMode( b )
	love.graphics.pop()
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
	if ( children == nil ) then
		return
	end

	local value = nil
	for _, v in ipairs( children ) do
		value = filtered( v, func, ... )
		if ( value ~= nil ) then
			return value
		end
	end
end

function panel:filedropped( file )
	return cascadeInputToChildren( self, "filedropped", file )
end

accessor( panel, "children" )
accessor( panel, "name" )
gui.accessor( panel, "opacity" )
accessor( panel, "parent" )
accessor( panel, "scale" )

function panel:getScheme( property )
	return scheme.getProperty( self.scheme, property )
end

gui.accessor( panel, "width",  nil, nil, 0 )
gui.accessor( panel, "height", nil, nil, 0 )

function panel:getSize()
	return self:getWidth(), self:getHeight()
end

accessor( panel, "x" )
accessor( panel, "y" )

function panel:getPos()
	return self:getX(), self:getY()
end

function panel:getTopMostChildAtPos( x, y )
	if ( not self:isVisible() ) then
		return nil
	end

	local sx, sy = self:localToScreen()
	local w,  h  = self:getSize()
	if ( not math.pointinrect( x, y, sx, sy, w, h ) ) then
		return nil
	end

	local children = self:getChildren()
	if ( children ) then
		for i = #children, 1, -1 do
			local topChild = children[ i ]:getTopMostChildAtPos( x, y )
			if ( topChild ) then
				return topChild
			end
		end
	end

	return self
end

function panel:invalidate()
	self.needsRedraw = true

	local parent = self:getParent()
	while ( parent ~= nil ) do
		parent:invalidate()
		parent = parent:getParent()
	end
end

function panel:invalidateFramebuffer()
	local children = self:getChildren()
	if ( children ) then
		for _, v in ipairs( children ) do
			v:invalidateFramebuffer()
		end
	end

	if ( self:shouldUseFullscreenFramebuffer() ) then
		self.framebuffer = nil
		self:createFramebuffer()
	end
end

function panel:invalidateLayout()
	local children = self:getChildren()
	if ( children ) then
		for _, v in ipairs( children ) do
			v:invalidateLayout()
		end
	end

	self:invalidate()
end

function panel:invalidateParent()
	self:getParent():invalidate()
end

function panel:isChildMousedOver()
	local panel = gui._topPanel
	while ( panel ~= nil ) do
		panel = panel:getParent()
		if ( self == panel ) then
			return true
		end
	end

	return false
end

function panel:isSiblingMousedOver()
	local parent = self:getParent()
	if ( parent == nil ) then
		return false
	end

	local children = parent:getChildren()
	if ( children == nil ) then
		return false
	end

	for _, v in ipairs( children ) do
		if ( v ~= self and v.mouseover ) then
			return true
		end
	end

	return false
end

function panel:isTopMostChild()
	local children = self:getChildren()
	if ( children ) then
		return children[ #children ] == self
	else
		return true
	end
end

gui.accessor( panel, "visible", "is" )

function panel:joystickpressed( joystick, button )
	return cascadeInputToChildren( self, "joystickpressed", joystick, button )
end

function panel:joystickreleased( joystick, button )
	return cascadeInputToChildren( self, "joystickreleased", joystick, button )
end

function panel:keypressed( key, scancode, isrepeat )
	return cascadeInputToChildren( self, "keypressed", key, scancode, isrepeat )
end

function panel:keyreleased( key, scancode )
	return cascadeInputToChildren( self, "keyreleased", key, scancode )
end

function panel:localToScreen( x, y )
	local posX, posY = x or self:getX(), y or self:getY()
	local parent     = self:getParent()
	while ( parent ~= nil ) do
		posX = posX + parent:getX()
		posY = posY + parent:getY()
		parent = parent:getParent()
	end

	return posX, posY
end

function panel:mousepressed( x, y, button, istouch )
	return cascadeInputToChildren( self, "mousepressed", x, y, button )
end

function panel:mousereleased( x, y, button, istouch )
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

function panel:moveToFront()
	local parent   = self:getParent()
	local children = nil
	if ( parent ) then
		children = parent:getChildren()
		if ( self == children[ #children ] ) then
			return
		end
	end

	if ( gui._focusedPanel ) then
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

function panel:moveToBack()
	local parent   = self:getParent()
	local children = nil
	if ( parent ) then
		children = parent:getChildren()
		if ( self == children[ 1 ] ) then
			return
		end
	end

	if ( gui._focusedPanel ) then
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

function panel:onMouseLeave()
end

function panel:onRemove()
end

function panel:preDraw()
	if ( not self:isVisible() ) then
		return
	end

	local scale = self:getScale()
	local width, height = self:getSize()
	love.graphics.push()
	love.graphics.translate( self:getX(), self:getY() )
	love.graphics.scale( scale )
	love.graphics.translate(
		( width  / scale ) / 2 - width  / 2,
		( height / scale ) / 2 - height / 2
	)
end

local gui_element_selection = convar(
	"gui_element_selection",
	"0",
	nil,
	nil,
	"Start element selection"
)

function panel:postDraw()
	if ( not self:isVisible() ) then
		return
	end

	if ( gui_element_selection:getBoolean() ) then
		if ( self.mouseover ) then
			self:drawSelection()
			self:drawName()
		end
	end

	love.graphics.pop()
end

function panel:preDrawWorld()
	local children = self:getChildren()
	if ( children ) then
		for _, v in ipairs( children ) do
			v:preDrawWorld()
		end
	end
end

function panel:remove()
	if ( self:getChildren() ) then
		self:removeChildren()
	end

	local parent = self:getParent()
	if ( parent ) then
		local children = parent:getChildren()
		for i, v in ipairs( children ) do
			if ( v == self ) then
				table.remove( children, i )
			end
		end

		if ( #children == 0 ) then
			parent.children = nil
		end
	end

	self:onRemove()
end

function panel:removeChildren()
	local children = self:getChildren()
	if ( children ) then
		for i = #children, 1, -1 do
			children[ i ]:remove()
		end
	end
	self:invalidate()
end

function panel:screenToLocal( x, y )
	local posX, posY = 0, 0
	local panel      = self
	while ( panel:getParent() ~= nil ) do
		posX = posX + panel:getX()
		posY = posY + panel:getY()
		panel = panel:getParent()
	end

	x = x - posX
	y = y - posY

	return x, y
end

function panel:setUseFullscreenFramebuffer( useFullscreenFramebuffer )
	self.useFullscreenFramebuffer = useFullscreenFramebuffer and true or nil
end

function panel:setNextThink( nextThink )
	self.nextThink = nextThink
end

function panel:setParent( panel )
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
	if ( table.hasvalue( panel.children, self ) ) then
		return
	end

	table.insert( panel.children, self )
	self.parent = panel
end

function panel:setScale( scale )
	self.scale = scale
	self:invalidate()
end

function panel:setScheme( name )
	if ( not scheme.isLoaded( name ) ) then
		scheme.load( name )
	end
	self.scheme = name
end

function panel:setWidth( width )
	self.width = math.round( width )
	self:invalidate()
end

function panel:setHeight( height )
	self.height = math.round( height )
	self:invalidate()
end

function panel:setSize( width, height )
	self:setWidth( width )
	self:setHeight( height )
end

function panel:setX( x )
	self.x = math.round( x )
	if ( self:getParent() ) then
		self:invalidateParent()
	end
end

function panel:setY( y )
	self.y = math.round( y )
	if ( self:getParent() ) then
		self:invalidateParent()
	end
end

function panel:setPos( x, y )
	self:setX( x )
	self:setY( y )
end

accessor( panel, "useFullscreenFramebuffer", "should" )

function panel:textinput( text )
	return cascadeInputToChildren( self, "textinput", text )
end

function panel:textedited( text, start, length )
	return cascadeInputToChildren( self, "textedited", text, start, length )
end

function panel:update( dt )
	if ( self.think     and
	     self.nextThink and
	     self.nextThink <= love.timer.getTime() ) then
		self.nextThink = nil
		self:think()
	end

	if ( self.animations ) then
		self:updateAnimations( dt )
	end

	local children = self:getChildren()
	if ( children == nil ) then
		return
	end

	for _, v in ipairs( children ) do
		v:update( dt )
	end
end

function panel:updateAnimations( dt )
	for _, animation in ipairs( self.animations ) do
		if ( animation.startTime == nil ) then
			animation.startTime = love.timer.getTime()
		end

		local startTime = animation.startTime
		local duration  = animation.duration
		local remaining = startTime + duration - love.timer.getTime()
		remaining       = math.max( 0, remaining )
		local percent   = 1 - ( remaining / duration or 0 )
		animation.pos   = percent

		for member, tween in pairs( animation.tweens ) do
			local startValue = tween.startValue
			local endValue   = tween.endValue
			local eased      = _G.tween.easing[ animation.easing ](
				percent, duration * percent, 0, 1, duration
			)
			self[ member ] = ( endValue - startValue ) * eased + startValue

			if ( animation.step ) then
				animation.step( self[ member ], tween )
			end

			self:invalidate()
		end

		if ( percent == 1 ) then
			local complete = animation.complete
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

	if ( table.len( self.animations ) == 0 ) then
		self.animations = nil
	end
end

function panel:wheelmoved( x, y )
	return cascadeInputToChildren( self, "wheelmoved", x, y )
end

function panel:__tostring()
	return "panel: \"" .. self.name .. "\" (" .. self.__type .. ")"
end
