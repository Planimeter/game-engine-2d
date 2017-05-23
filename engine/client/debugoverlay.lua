--=========== Copyright © 2017, Planimeter, All rights reserved. ===========--
--
-- Purpose: Debug Overlay interface
--
--==========================================================================--

local _G = _G

module( "debugoverlay" )

function rectangle( x, y, width, height, color, duration )
	if ( _G.g_DebugOverlay ) then
		_G.g_DebugOverlay:rectangle( x, y, width, height, color, duration )
	end
end
