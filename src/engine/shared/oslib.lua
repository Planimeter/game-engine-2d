--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Extends the os library
--
--============================================================================--

local system = love.system
local mouse  = love.mouse

if ( _CLIENT or _INTERACTIVE ) then
	function os.getClipboardText()
		return system.getClipboardText()
	end
end

function os.getOS()
	return system.getOS()
end

_WINDOWS = os.getOS() == "Windows"
_OSX     = os.getOS() == "OS X"
_LINUX   = os.getOS() == "Linux"

if ( _CLIENT or _INTERACTIVE ) then
	local cursor        = nil
	local cursors       = {}
	local systemCursors = {
		"sizens",
		"sizenesw",
		"sizewe",
		"sizenwse",
		"sizens",
		"sizenesw",
		"sizewe",
		"sizenwse",
		"ibeam"
	}

	do
		for _, ctype in pairs( systemCursors ) do
			cursors[ ctype ] = mouse.getSystemCursor( ctype )
		end
	end

	function os.setCursor( ctype )
		if ( ctype == nil ) then
			mouse.setCursor()
			cursor = nil
			return
		end

		if ( ctype == cursor ) then
			return
		end

		if ( not cursors[ ctype ] ) then
			cursors[ ctype ] = mouse.newCursor( ctype )
		end

		mouse.setCursor( cursors[ ctype ] )
		cursor = ctype
	end

	function os.setCursorVisible( visible )
		mouse.setVisible( visible )
	end
end
