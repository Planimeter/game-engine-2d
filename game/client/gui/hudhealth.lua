--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Health HUD
--
--============================================================================--

class "hudhealth" ( gui.panel )

function hudhealth:hudhealth( parent )
	gui.panel.panel( self, parent, "HUD Health" )
	self.width = point( 102 )

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
	graphics.setColor( self:getScheme( property ) )
	local font = self:getScheme( "entityFont" )
	graphics.setFont( font )
	local health = localplayer:getNetworkVar( "health" )
	graphics.print(
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
	graphics.setColor( self:getScheme( property ) )
	local font = self:getScheme( "entityFont" )
	local lineHeight = font:getHeight()
	font = self:getScheme( "font" )
	graphics.setFont( font )
	graphics.print( "Health", 0, lineHeight )
end

function hudhealth:invalidateLayout()
	local margin = gui.scale( 96 )
	local viewportHeight = graphics.getViewportHeight()
	local height = self:getHeight()
	self:setPos( margin, viewportHeight - margin - height )

	gui.panel.invalidateLayout( self )
end

gui.register( hudhealth, "hudhealth" )
