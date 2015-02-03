--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Extends the os library
--
--============================================================================--

if ( _CLIENT or _INTERACTIVE ) then
local system = love.system
local mouse  = love.mouse

function os.getClipboardText()
	return system.getClipboardText()
end

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
	for _, v in pairs( systemCursors ) do
		cursors[ v ] = mouse.getSystemCursor( v )
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
