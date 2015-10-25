--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Game Menu Stats class
--
--============================================================================--

class "hudgamemenustats" ( gui.panel )

function hudgamemenustats:hudgamemenustats( parent )
	gui.panel.panel( self, parent, "Stats" )
	self:setScheme( "Default" )
	self:setSize( parent:getSize() )
end

function hudgamemenustats:draw()
	local property = "button.disabled.textColor"

	graphics.setColor( self:getScheme( property ) )

	local font = self:getScheme( "fontBold" )
	graphics.setFont( font )
	local x = self:getWidth()  / 2 - font:getWidth( self:getName() .. " Placeholder" ) / 2
	local y = self:getHeight() / 2 - font:getHeight()                / 2 - 2
	graphics.print( self:getName() .. " Placeholder", x, y )
end

gui.register( hudgamemenustats, "hudgamemenustats" )
