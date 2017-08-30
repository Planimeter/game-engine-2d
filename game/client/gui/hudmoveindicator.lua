--=========== Copyright © 2017, Planimeter, All rights reserved. ===========--
--
-- Purpose: Move Indicator HUD
--
--==========================================================================--

class "gui.hudmoveindicator" ( "gui.panel" )

local hudmoveindicator = gui.hudmoveindicator

function hudmoveindicator:hudmoveindicator( parent )
	local name   = "HUD Move Indicator"
	gui.panel.panel( self, parent, name )
	self.width   = love.graphics.getWidth()
	self.height  = love.graphics.getHeight()
	self:setUseFullscreenFramebuffer( true )

	self.options = gui.optionsitemgroup( self, name .. " Options Item Group" )
	self.options:setWidth( love.window.toPixels( 216 ) )
	self.optionsActive = false

	self:setScheme( "Default" )
end

local function updateSprites( self, sprite, i, v )
	if ( v.sprite ~= sprite ) then
		return
	end

	table.remove( self.sprites, i )

	if ( #self.sprites == 0 ) then
		self.sprites = nil
	end
end

local function onAnimationEnd( self )
	return function( sprite )
		for i, v in ipairs( self.sprites ) do
			updateSprites( self, sprite, i, v )
		end
	end
end

function hudmoveindicator:createMoveIndicator( worldIndex, x, y )
	if ( self.sprites == nil ) then
		self.sprites = {}
	end

	local sprite = sprite( "images.moveindicator" )
	sprite.onAnimationEnd = onAnimationEnd( self )

	local indicator = {
		sprite     = sprite,
		worldIndex = worldIndex,
		x          = x,
		y          = y
	}
	indicator.sprite:setAnimation( "click" )
	table.insert( self.sprites, indicator )
end

local r_draw_position = convar( "r_draw_position", "0", nil, nil,
                                "Draws position" )

function hudmoveindicator:preDrawWorld()
	self:drawMoveIndicators()

	if ( r_draw_position:getBoolean() and love.window.hasFocus() ) then
		self:drawPosition()
	end

	gui.panel.preDrawWorld( self )
end

function hudmoveindicator:draw()
	self:drawEntityName()
	self:drawEntityInfo()

	gui.panel.draw( self )
end

local function drawPosition( self, x, y, drawLabel )
	if ( drawLabel == nil ) then
		drawLabel = true
	end

	return function()
		love.graphics.setColor( color( color.white, 0.14 * 255 ) )
		local lineWidth = 1
		love.graphics.setLineWidth( lineWidth )
		local size = game.tileSize
		love.graphics.rectangle(
			"line",
			lineWidth / 2,
			lineWidth / 2,
			size - lineWidth,
			size - lineWidth
		)
		if ( not drawLabel ) then
			return
		end
		love.graphics.push()
			love.graphics.scale( 1 / camera.getZoom() )
			local font = self:getScheme( "fontSmall" )
			love.graphics.setFont( font )
			local position = vector( x, y ) + vector( 0, game.tileSize )
			y = ( size + 1 ) * camera.getZoom()
			love.graphics.print( tostring( position ), 0, y )
		love.graphics.pop()
	end
end

function hudmoveindicator:drawPosition()
	local worldIndex = localplayer:getWorldIndex()
	local x, y = love.mouse.getPosition()
	x, y = camera.screenToWorld( x, y )
	local rx, ry = 0, 0
	if ( r_draw_position:getNumber() == 1 ) then
		rx, ry = region.snapToGrid( x, y )
	elseif ( r_draw_position:getNumber() == 2 ) then
		rx, ry = region.roundToGrid( x, y )
	end

	local drawLabel = r_draw_position:getNumber() == 1
	camera.drawToWorld(
		worldIndex,
		rx,
		ry,
		drawPosition( self, rx, ry, drawLabel )
	)

	if ( r_draw_position:getNumber() == 2 ) then
		camera.drawToWorld( worldIndex, x, y, drawPosition( self, x, y ) )
	end
end

function hudmoveindicator:drawEntityName()
	if ( self.entity == nil ) then
		return
	end

	local property = "hudmoveindicator.textColor"
	love.graphics.setColor( self:getScheme( property ) )
	local font = self:getScheme( "entityFont" )
	love.graphics.setFont( font )
	local name = self.entity:getName()
	local margin = gui.scale( 96 )
	love.graphics.print(
		name or "unnamed",   -- text
		margin, -- x
		margin, -- y
		0,      -- r
		1,      -- sx
		1,      -- sy
		0,      -- ox
		0,      -- oy
		0,      -- kx
		0,      -- ky
		2       -- tracking
	)
end

local function drawLevel( self, x, y )
	local l = self.entity:getLevel()
	love.graphics.print( "Level " .. l, x, y )
end

local function drawOptions( self, x, y )
	local options = self.entity:getOptions()
	local n = options and table.len( options ) or 0
	if ( n == 0 ) then
		return
	end

	local plural = n > 1 and "s" or ""
	love.graphics.print( n  .. " Option" .. plural, x, y )
end

function hudmoveindicator:drawEntityInfo()
	if ( self.entity == nil ) then
		return
	end

	local property = "hudmoveindicator.smallTextColor"
	love.graphics.setColor( self:getScheme( property ) )
	local font = self:getScheme( "entityFont" )
	local margin = gui.scale( 96 )
	local lineHeight = font:getHeight()
	font = self:getScheme( "font" )
	love.graphics.setFont( font )

	if ( self.entity.getLevel ) then
		drawLevel( self, margin, margin + lineHeight )
		lineHeight = lineHeight + font:getHeight()
	end

	if ( self.entity.getOptions ) then
		drawOptions( self, margin, margin + lineHeight )
	end
end

function hudmoveindicator:drawMoveIndicators()
	if ( self.sprites == nil ) then
		return
	end

	local property = "hudmoveindicator.indicatorColor"
	local color    = self:getScheme( property )
	for _, indicator in ipairs( self.sprites ) do
		local width      = indicator.sprite:getWidth()
		local height     = indicator.sprite:getHeight()
		local worldIndex = indicator.worldIndex
		local x          = indicator.x - width / 2
		local y          = indicator.y - height / 2
		camera.drawToWorld( worldIndex, x, y, function()
			love.graphics.setColor( color )
			indicator.sprite:draw()
		end )
	end
end

function hudmoveindicator:invalidateLayout()
	self:setWidth( love.graphics.getWidth() )
	self:setHeight( love.graphics.getHeight() )

	self.options:invalidateLayout()

	gui.panel.invalidateLayout( self )
end

accessor( hudmoveindicator, "active", "optionsActive", "is" )

local t = {}
local pointinrect = math.pointinrect

local getEntitiesAtMousePos = function( px, py )
	table.clear( t )
	local entities = entity.getAll()
	for _, entity in ipairs( entities ) do
		local x, y   = camera.worldToScreen( entity:getDrawPosition() )
		local sprite = entity:getSprite()
		local scale  = camera.getZoom()
		if ( sprite ) then
			local width  = sprite:getWidth()  * scale
			local height = sprite:getHeight() * scale
			if ( pointinrect( px, py, x, y, width, height ) ) then
				table.insert( t, entity )
			end
		end
	end
	return t
end

local function onLeftClick( self, x, y )
	if ( self.mouseover or self:isSiblingMousedOver() ) then
		self.mousedown = true
		self:invalidate()
		self:setActive( false )

		local player     = localplayer
		local worldIndex = player:getWorldIndex()
		local position   = vector( camera.screenToWorld( x, y ) )
		self:createMoveIndicator( worldIndex, position.x, position.y )
		player:moveTo( position + vector( 0, game.tileSize ) )

		return true
	else
		if ( self:isActive() and not self:isChildMousedOver() ) then
			self:setActive( false )
		end
	end
end

local function getOptionsFromEntities( x, y )
	local entities = getEntitiesAtMousePos( x, y )
	local t = {}
	for _, entity in ipairs( entities ) do
		local options = entity.getOptions and entity:getOptions() or nil
		if ( options ) then
			table.append( t, options )
		end
	end
	return t
end

local function onRightClick( self, x, y )
	local options = self.options
	options:removeChildren()
	options:setPos( x, y )
	self:setActive( true )

	local opts             = getOptionsFromEntities( x, y )
	local dropdownlistitem = nil
	local name             = "Option Drop-Down List Item"
	for i, option in pairs( opts ) do
		dropdownlistitem = gui.dropdownlistitem( name .. " " .. i, option.name )
		dropdownlistitem:setValue( option.value )
		options:addItem( dropdownlistitem )
	end

	return #opts > 0
end

function hudmoveindicator:mousepressed( x, y, button, istouch )
	if ( button == 1 ) then
		if ( onLeftClick( self, x, y ) ) then
			return
		end
	end

	if ( button == 2 ) then
		if ( onRightClick( self, x, y ) ) then
			return
		end
	end

	return gui.panel.mousepressed( self, x, y, button, istouch )
end

function hudmoveindicator:onValueChanged( oldValue, newValue )
end

function hudmoveindicator:setActive( active )
	self.optionsActive = active
	gui.setFocusedPanel( self, active )
end

function hudmoveindicator:update( dt )
	local mx, my = love.mouse.getPosition()
	local entity = getEntitiesAtMousePos( mx, my )[ 1 ]
	self.entity  = entity

	local sprites = self.sprites
	if ( sprites ) then
		for _, indicator in ipairs( sprites ) do
			indicator.sprite:update( dt )
		end
	end

	self:invalidate()
end
