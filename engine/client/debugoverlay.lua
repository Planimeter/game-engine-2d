--=========== Copyright © 2017, Planimeter, All rights reserved. ===========--
--
-- Purpose: Debug Overlay interface
--
--==========================================================================--

local _G = _G

module( "debugoverlay" )

function rectangle( x, y, width, height, color, duration )
	local g_DebugOverlay = _G.g_DebugOverlay
	if ( g_DebugOverlay ) then
		g_DebugOverlay:rectangle( x, y, width, height, color, duration )
	end
end
