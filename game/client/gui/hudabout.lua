--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: About HUD
--
--==========================================================================--

class "gui.hudabout" ( "gui.box" )

local hudabout = gui.hudabout

function hudabout:hudabout( parent )
	gui.box.box( self, parent, "HUD About" )
end
