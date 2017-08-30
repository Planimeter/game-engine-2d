--=========== Copyright © 2017, Planimeter, All rights reserved. ===========--
--
-- Purpose: Chat interface
--
--==========================================================================--

local love     = love
local math     = math
local select   = select
local string   = string
local table    = table
local tostring = tostring
local _G       = _G

module( "chat" )

function addText( ... )
	local args = { ... }
	table.tostring( args )

	local chat = _G.g_Chat.output
	local text = table.concat( args, "\t" )
	chat:activate()
	chat:insertText( text .. "\n" )

	local readingtime = math.max( string.readingtime( text ), 5 )
	chat:setHideTime( love.timer.getTime() + readingtime )
end
