--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Chat interface
--
--==========================================================================--

local love     = love
local math     = math
local string   = string
local table    = table
local tostring = tostring
local _G       = _G

module( "chat" )

function addText( ... )
	if ( _G.g_Chat == nil ) then
		return
	end

	local args = { ... }
	table.tostring( args )

	local chat = _G.g_Chat.output
	local text = table.concat( args, "\t" )
	chat:activate()
	chat:insertText( text .. "\n" )

	local readingtime = math.max( string.readingtime( text ), 5 )
	chat:setHideTime( love.timer.getTime() + readingtime )
end
