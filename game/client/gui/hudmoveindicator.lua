--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Move Indicator HUD
--
--==========================================================================--

class "gui.hudmoveindicator" ( "gui.box" )

local hudmoveindicator = gui.hudmoveindicator

function hudmoveindicator:hudmoveindicator( parent )
	local name   = "HUD Move Indicator"
	gui.box.box( self, parent, name )
	self.width   = love.graphics.getWidth()
	self.height  = love.graphics.getHeight()
	self:setUseFullscreenCanvas( true )

	self:setPadding( gui.scale( 96 ) )
	self:setDisplay( "block" )
	self:setPosition( "absolute" )

	self.options = gui.optionsitemgroup( self, name .. " Options Item Group" )
	self.options:setParent( self )
	self.options:setWidth( 216 )
	self.optionsActive = false

	self:setScheme( "Default" )
end

local function updateSprites( self, sprite, i, v )
	if ( v.sprite ~= sprite ) then
		return
	end

	table.remove( self._sprites, i )

	if ( #self._sprites == 0 ) then
		self._sprites = nil
	end
end

local function onAnimationEnd( self )
	return function( sprite )
		for i, v in ipairs( self._sprites ) do
			updateSprites( self, sprite, i, v )
		end
	end
end

function hudmoveindicator:createMoveIndicator( worldIndex, x, y )
	if ( self._sprites == nil ) then
		self._sprites = {}
	end

	local sprite = sprite( "images.moveindicator" )
	sprite:setFilter( "nearest", "nearest" )
	sprite.onAnimationEnd = onAnimationEnd( self )

	local indicator = {
		sprite     = sprite,
		worldIndex = worldIndex,
		x          = x,
		y          = y
	}
	indicator.sprite:setAnimation( "click" )
	table.insert( self._sprites, indicator )
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

local function drawLabel( self, x, y )
	love.graphics.push()
	love.graphics.scale( 1 / camera.getZoom() )

	local font = scheme.getProperty( "Console", "font" )
	love.graphics.setFont( font )

	local position = vector( x, y ) + vector( 0, game.tileSize )
	position = tostring( position )
	position = string.gsub( position, "vector", "position" )

	local size = game.tileSize
	y = ( size + 1 ) * camera.getZoom()

	love.graphics.print( position, 0, y )
	love.graphics.pop()
end

local function drawPosition( self, x, y, shouldDrawLabel )
	shouldDrawLabel = shouldDrawLabel or true

	return function()
		love.graphics.setColor( color.red )

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

		if ( shouldDrawLabel ) then
			drawLabel( self, x, y )
		end
	end
end

function hudmoveindicator:drawPosition()
	local worldIndex = localplayer:getWorldIndex()
	local x, y = love.mouse.getPosition()
	x, y = camera.screenToWorld( x, y )

	local rx, ry = 0, 0
	if ( r_draw_position:getNumber() == 1 ) then
		rx, ry = map.snapToGrid( x, y )
	elseif ( r_draw_position:getNumber() == 2 ) then
		rx, ry = map.roundToGrid( x, y )
	end

	local shouldDrawLabel = r_draw_position:getNumber() == 1
	camera.drawToWorld(
		worldIndex,
		rx,
		ry,
		drawPosition( self, rx, ry, shouldDrawLabel )
	)

	if ( r_draw_position:getNumber() == 2 ) then
		camera.drawToWorld( worldIndex, x, y, drawPosition( self, x, y ) )
	end
end

function hudmoveindicator:drawEntityName()
	if ( self._entity == nil ) then
		return
	end

	local property = "hudmoveindicator.textColor"
	love.graphics.setColor( self:getScheme( property ) )

	local font = self:getScheme( "entityFont" )
	love.graphics.setFont( font )

	-- "Use" mode
	local text = self._entity:getName() or "unnamed"
	local item = g_Inventory:getSelectedItem()
	if ( item ) then
		item = item:getItemClass()

		local name = item.data.name
		text = "Use " .. name .. " with " .. text
	end

	local margin = gui.scale( 96 )
	love.graphics.print(
		text,   -- text
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
	local l = self._entity:getLevel()
	love.graphics.print( "Level " .. l, x, y )
end

local function drawOptions( self, x, y )
	local options = self._entity:getOptions()
	local n = options and table.len( options ) or 0
	if ( n == 0 ) then
		return
	end

	local plural = n > 1 and "s" or ""
	love.graphics.print( n  .. " Option" .. plural, x, y )
end

function hudmoveindicator:drawEntityInfo()
	if ( self._entity == nil ) then
		return
	end

	local property = "hudmoveindicator.smallTextColor"
	love.graphics.setColor( self:getScheme( property ) )

	local font = self:getScheme( "entityFont" )
	local margin = gui.scale( 96 )
	local lineHeight = font:getHeight()
	font = self:getScheme( "font" )
	love.graphics.setFont( font )

	if ( self._entity.getLevel ) then
		drawLevel( self, margin, margin + lineHeight )
		lineHeight = lineHeight + font:getHeight()
	end

	if ( self._entity.getOptions ) then
		drawOptions( self, margin, margin + lineHeight )
	end
end

function hudmoveindicator:drawMoveIndicators()
	if ( self._sprites == nil ) then
		return
	end

	local property = "hudmoveindicator.indicatorColor"
	local color    = self:getScheme( property )
	for _, indicator in ipairs( self._sprites ) do
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

accessor( hudmoveindicator, "active", "is", "optionsActive" )

local t = {}
local pointinrect = math.pointinrect

local getEntitiesAtMousePos = function( px, py )
	table.clear( t )

	local entities = entity.getAll()
	table.foreachi( entities, function( _, entity )
		if ( typeof( entity, "trigger" ) ) then
			return
		end

		local x, y   = camera.worldToScreen( entity:getDrawPosition() )
		local sprite = entity:getSprite()
		local scale  = camera.getZoom()
		if ( sprite == nil ) then
			return
		end

		local width  = sprite:getWidth()  * scale
		local height = sprite:getHeight() * scale
		if ( pointinrect( px, py, x, y, width, height ) ) then
			table.insert( t, entity )
		end
	end )
	return t
end

local function moveTo( self, x, y )
	local player     = localplayer
	local worldIndex = player:getWorldIndex()
	local position   = vector( x, y )
	self:createMoveIndicator( worldIndex, position.x, position.y )

	position.x, position.y = map.snapToGrid( position.x, position.y )
	player:moveTo( position + vector( 0, game.tileSize ) )
end

local function onLeftClick( self, x, y )
	if ( self.mouseover or self:isSiblingMousedOver() ) then
		self.mousedown = true
		self:invalidate()
		self:setActive( false )

		x, y = camera.screenToWorld( x, y )
		moveTo( self, x, y )

		return true
	else
		if ( self:isActive() and not self:isChildMousedOver() ) then
			self:setActive( false )
		end
	end
end

local function getOptionsFromEntities( x, y )
	local t = {}
	local entities = getEntitiesAtMousePos( x, y )
	table.foreachi( entities, function( _, entity )
		local options = entity.getOptions and entity:getOptions() or nil
		if ( options == nil ) then
			return
		end

		table.insert( t, {
			entity  = entity,
			options = options
		} )
	end )
	return t
end

local function noop()
end

local function onRightClick( self, x, y )
	if ( not self.mouseover ) then
		return
	end

	local options = self.options
	options:removeChildren()
	options:setPos( x, y )
	self:setActive( true )

	local opts        = getOptionsFromEntities( x, y )
	local optionsitem = nil
	local name        = "Option Item"
	local n           = 1
	for i, entity in pairs( opts ) do
		for j, option in pairs( entity.options ) do
			local panelName = name .. " " .. n
			optionsitem = gui.optionsitem( options, panelName, option.name )
			optionsitem:setEntity( entity.entity )
			optionsitem:setValue( option.value )
			n = n + 1
		end
	end

	x, y = camera.screenToWorld( x, y )
	optionsitem = gui.optionsitem( options, name .. " " .. n, "Walk here" )
	optionsitem:setValue( function()
		moveTo( self, x, y )
	end )
	n = n + 1

	optionsitem = gui.optionsitem( options, name .. " " .. n, "Cancel" )
	optionsitem:setValue( noop )
	n = n + 1

	return n > 1
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
	local needsRedraw = false
	if ( self._entity ~= entity ) then
		self._entity = entity
		needsRedraw = true
	end

	local sprites = self._sprites
	if ( sprites ) then
		for _, indicator in ipairs( sprites ) do
			indicator.sprite:update( dt )
		end
		needsRedraw = true
	end

	if ( needsRedraw ) then
		self:invalidate()
	end
end
