--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Health HUD
--
--============================================================================--

class "hudhealth" ( gui.panel )

function hudhealth:hudhealth( parent )
	gui.panel.panel( self, parent, "HUD Health" )
	self.width = point( 64 )
	self.height = point( 64 )

	self:setScheme( "Default" )
end

function hudhealth:draw()
	self:drawLabel()
	self:drawHealth()

	gui.panel.draw( self )
end

function hudhealth:drawLabel()
end

function hudhealth:drawHealth()
	local property = "hudmoveindicator.textColor"
	graphics.setColor( self:getScheme( property ) )
	local font = self:getScheme( "entityFont" )
	graphics.setFont( font )
	local health = localplayer:getNetworkVar( "health" )
	local margin = gui.scale( 96 )
	graphics.print(
		health, -- text
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

gui.register( hudhealth, "hudhealth" )
