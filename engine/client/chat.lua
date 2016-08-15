--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Chat interface
--
--============================================================================--

local _CLIENT  = _CLIENT

local engine   = engine
local math     = math
local select   = select
local string   = string
local table    = table
local tostring = tostring
local _G       = _G

module( "chat" )

function addText( ... )
	local args = { ... }
	for i = 1, select( "#", ... ) do
		args[ i ] = tostring( args[ i ] )
	end

	if ( _CLIENT ) then
		local chat = _G.g_Chat.output
		local text = table.concat( args, "\t" )
		chat:activate()
		chat:insertText( text .. "\n" )

		local readingtime = math.max( string.readingtime( text ), 5 )
		chat:setHideTime( engine.getRealTime() + readingtime )
	end
end
