--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Game Menu Inventory Button class
--
--============================================================================--

class "hudgamemenuinventorybutton" ( gui.button )

function hudgamemenuinventorybutton:hudgamemenuinventorybutton( parent, name )
	gui.button.button( self, parent, name, name )
end

gui.register( hudgamemenuinventorybutton, "hudgamemenuinventorybutton" )
