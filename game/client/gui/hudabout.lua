--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: About HUD
--
--==========================================================================--

class "gui.hudabout" ( "gui.panel" )

local hudabout = gui.hudabout

function hudabout:hudabout( parent )
	gui.panel.panel( self, parent, "HUD About" )
end
