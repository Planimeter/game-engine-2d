--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Voice HUD
--
--==========================================================================--

class "gui.hudvoice" ( "gui.box" )

local hudvoice = gui.hudvoice

function hudvoice:hudvoice( parent, name )
	gui.box.box( self, parent, name )
end

function hudvoice:draw()
	gui.box.draw( self )
end
