--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: Mana HUD
--
--==========================================================================--

class "gui.hudmana" ( "gui.panel" )

local hudmana = gui.hudmana

function hudmana:hudmana( parent )
	gui.panel.panel( self, parent, "HUD Mana" )

	self:setScheme( "Default" )
	local font = self:getScheme( "entityFont" )
	self.height = font:getHeight()
	font = self:getScheme( "font" )
	self.width = font:getWidth( "Mana" )
	self.height = self.height + font:getHeight()

	self:invalidateLayout()
end

function hudmana:draw()
	self:drawLabel()
	self:drawMana()

	gui.panel.draw( self )
end

function hudmana:drawMana()
	local property = "hudmoveindicator.textColor"
	love.graphics.setColor( self:getScheme( property ) )
	local font = self:getScheme( "entityFont" )
	love.graphics.setFont( font )
	local mana = localplayer:getNetworkVar( "mana" )
	love.graphics.print(
		mana, -- text
		0, -- x
		0, -- y
		0, -- r
		1, -- sx
		1, -- sy
		0, -- ox
		0, -- oy
		0, -- kx
		0, -- ky
		2  -- tracking
	)
end

function hudmana:drawLabel()
	local property = "hudmoveindicator.smallTextColor"
	love.graphics.setColor( self:getScheme( property ) )
	local font = self:getScheme( "entityFont" )
	local lineHeight = font:getHeight()
	font = self:getScheme( "font" )
	love.graphics.setFont( font )
	love.graphics.print( "Mana", 0, math.round( lineHeight ) )
end

function hudmana:invalidateLayout()
	local margin = gui.scale( 96 )
	local graphicsHeight = love.graphics.getHeight()
	local height = self:getHeight()
	self:setPos(
		margin + g_HudHealth:getWidth() + margin / 2,
		graphicsHeight - margin - height
	)

	gui.panel.invalidateLayout( self )
end
