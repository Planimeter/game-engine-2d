--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Debug Overlay interface
--
--============================================================================--

class( "debugoverlay" )

function debugoverlay.rectangle( x, y, width, height, color, duration )
	if ( g_DebugOverlay ) then
		g_DebugOverlay:rectangle( x, y, width, height, color, duration )
	end
end
