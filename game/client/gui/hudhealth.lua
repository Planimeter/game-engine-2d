--=========== Copyright © 2017, Planimeter, All rights reserved. ===========--
--
-- Purpose: Health HUD
--
--==========================================================================--

class "gui.hudhealth" ( "gui.panel" )

local hudhealth = gui.hudhealth

function hudhealth:hudhealth( parent )
	gui.panel.panel( self, parent, "HUD Health" )
	self.width = love.window.toPixels( 102 )

	self:setScheme( "Default" )
	local font = self:getScheme( "entityFont" )
	self.height = font:getHeight()
	font = self:getScheme( "font" )
	self.height = self.height + font:getHeight()

	self:invalidateLayout()
end

function hudhealth:draw()
	self:drawLabel()
	self:drawHealth()

	gui.panel.draw( self )
end

function hudhealth:drawHealth()
	local property = "hudmoveindicator.textColor"
	love.graphics.setColor( self:getScheme( property ) )
	local font = self:getScheme( "entityFont" )
	love.graphics.setFont( font )
	local health = localplayer:getNetworkVar( "health" )
	love.graphics.print(
		health, -- text
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

function hudhealth:drawLabel()
	local property = "hudmoveindicator.smallTextColor"
	love.graphics.setColor( self:getScheme( property ) )
	local font = self:getScheme( "entityFont" )
	local lineHeight = font:getHeight()
	font = self:getScheme( "font" )
	love.graphics.setFont( font )
	love.graphics.print( "Health", 0, math.round( lineHeight ) )
end

function hudhealth:invalidateLayout()
	local margin = gui.scale( 96 )
	local graphicsHeight = love.graphics.getHeight()
	local height = self:getHeight()
	self:setPos( margin, graphicsHeight - margin - height )

	gui.panel.invalidateLayout( self )
end
