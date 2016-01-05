--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Debug Overlay interface
--
--============================================================================--

local _G = _G

module( "debugoverlay" )

function rectangle( x, y, width, height, color, duration )
	_G.g_DebugOverlay:rectangle( x, y, width, height, color, duration )
end
