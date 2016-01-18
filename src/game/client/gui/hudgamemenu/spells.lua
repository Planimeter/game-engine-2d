--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Game Menu Spells class
--
--============================================================================--

class "hudgamemenuspells" ( gui.panel )

function hudgamemenuspells:hudgamemenuspells( parent )
	gui.panel.panel( self, parent, "Spells" )
	self:setScheme( "Default" )
	self:setSize( parent:getSize() )
end

gui.register( hudgamemenuspells, "hudgamemenuspells" )
