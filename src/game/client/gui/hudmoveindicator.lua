--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Move Indicator HUD
--
--============================================================================--

class "hudmoveindicator" ( gui.panel )

function hudmoveindicator:hudmoveindicator( parent )
	local name = "HUD Move Indicator"
	gui.panel.panel( self, parent, name )
	self.width   = graphics.getViewportWidth()
	self.height  = graphics.getViewportHeight()

	self.options = gui.optionsitemgroup( self, name .. " Options Item Group" )

	self:setScheme( "Default" )
end

function hudmoveindicator:createMoveIndicator( x, y )
	if ( not self.sprites ) then
		self.sprites = {}
	end

	local sprite = sprite( "images.moveindicator" )
	sprite.onAnimationEnd = function( sprite )
		for i, v in ipairs( self.sprites ) do
			if ( v.sprite == sprite ) then
				table.remove( self.sprites, i )

				if ( #self.sprites == 0 ) then
					self.sprites = nil
				end
			end
		end
	end

	local indicator = {
		sprite = sprite,
		x      = x,
		y      = y
	}
	indicator.sprite:setAnimation( "click" )
	table.insert( self.sprites, indicator )
end

function hudmoveindicator:preDrawWorld()
	self:drawMoveIndicators()

	gui.panel.preDrawWorld( self )
end

function hudmoveindicator:draw()
	self:drawEntityName()

	gui.panel.draw( self )
end

function hudmoveindicator:drawEntityName()
	if ( not self.entity ) then
		return
	end

	local property = "hudmoveindicator.textColor"
	graphics.setColor( self:getScheme( property ) )
	local font = self:getScheme( "entityFont" )
	graphics.setFont( font )
	local name = self.entity:getName()
	local margin = gui.scale( 96 )
	graphics.print(
		name,   -- text
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

	if ( not self.entity.getOptions ) then
		return
	end

	property = "hudmoveindicator.smallTextColor"
	graphics.setColor( self:getScheme( property ) )

	local lineHeight = font:getHeight()
	font = self:getScheme( "font" )
	graphics.setFont( font )

	local n      = table.len( self.entity:getOptions() )
	local plural = n > 1 and "s" or ""
	graphics.print( n  .. " Option" .. plural, margin, margin + lineHeight )
end

function hudmoveindicator:drawMoveIndicators()
	if ( not self.sprites ) then
		return
	end

	local property = "hudmoveindicator.indicatorColor"
	local color    = self:getScheme( property )
	for _, indicator in ipairs( self.sprites ) do
		local width  = indicator.sprite:getWidth()
		local height = indicator.sprite:getHeight()
		local x      = indicator.x - width / 2
		local y      = indicator.y - height / 2
		camera.drawToWorld( x, y, function()
			graphics.setColor( color )
			indicator.sprite:draw()
		end )
	end
end

function hudmoveindicator:invalidateLayout()
	self:setWidth( graphics.getViewportWidth() )
	self:setHeight( graphics.getViewportHeight() )

	self.options:invalidateLayout()

	gui.panel.invalidateLayout( self )
end

function hudmoveindicator:isActive()
	return self:isVisible() and true or false
end

local t = {}
local pointinrectangle = math.pointinrectangle

local getEntitiesAtMousePos = function( px, py )
	table.clear( t )
	local entities = entity.getAll()
	for _, entity in ipairs( entities ) do
		local x, y   = camera.worldToScreen( entity:getDrawPosition() )
		local sprite = entity:getSprite()
		if ( sprite and sprite ~= graphics.error ) then
			local width  = sprite:getWidth()
			local height = sprite:getHeight()
			if ( pointinrectangle( px, py, x, y, width, height ) ) then
				table.insert( t, entity )
			end
		end
	end
	return t
end

local function onLeftClick( self, x, y )
	local options = self.options
	if ( options:isVisible() ) then
		options:setVisible( false )
	end

	local player   = localplayer
	local position = vector( camera.screenToWorld( x, y ) )
	self:createMoveIndicator( position.x, position.y )
	player:moveTo( position )
end

local function getOptionsFromEntities( x, y )
	local entities = getEntitiesAtMousePos( x, y )
	local t = {}
	for _, entity in ipairs( entities ) do
		local options = entity.getOptions and entity:getOptions() or nil
		if ( options ) then
			-- table.append( t, options )
		end
	end
	return t
end

local function onRightClick( self, x, y )
	local options = self.options
	if ( not options:isVisible() ) then
		options:setVisible( true )
	end

	options:setPos( x, y )

	local options          = getOptionsFromEntities( x, y )
	local dropdownlistitem = nil
	local name             = "Option Drop-Down List Item"
	for i, options in pairs( options ) do
		dropdownlistitem = gui.dropdownlistitem( name .. " " .. i, options.name )
		dropdownlistitem:setValue( options.value )
		options:addItem( dropdownlistitem )
	end
end

function hudmoveindicator:mousepressed( x, y, button )
	if ( not self:isVisible() ) then
		return
	end

	if ( not self.mouseover ) then
		return
	end

	if ( button == "l" ) then
		onLeftClick( self, x, y )
	end

	if ( button == "r" ) then
		onRightClick( self, x, y )
	end
end

local mouseX, mouseY   = 0, 0
local getMousePosition = input.getMousePosition

function hudmoveindicator:update( dt )
	mouseX, mouseY = getMousePosition()
	local entity   = getEntitiesAtMousePos( mouseX, mouseY )[ 1 ]
	self.entity    = entity

	local sprites = self.sprites
	if ( sprites ) then
		for _, indicator in ipairs( sprites ) do
			indicator.sprite:update( dt )
		end
	end

	self:invalidate()
end

gui.register( hudmoveindicator, "hudmoveindicator" )
