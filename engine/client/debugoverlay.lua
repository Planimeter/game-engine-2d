--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: Debug Overlay interface
--
--==========================================================================--

local _G = _G

module( "debugoverlay" )

function line( worldIndex, x, y, points, color, duration )
	local g_DebugOverlay = _G.g_DebugOverlay
	if ( g_DebugOverlay == nil ) then
		return
	end

	g_DebugOverlay:line( worldIndex, x, y, points, color, duration )
end

function rectangle( worldIndex, x, y, width, height, color, duration )
	local g_DebugOverlay = _G.g_DebugOverlay
	if ( g_DebugOverlay == nil ) then
		return
	end

	g_DebugOverlay:rectangle(
		worldIndex,
		x,
		y,
		width,
		height,
		color,
		duration
	)
end
