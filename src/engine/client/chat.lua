--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Chat interface
--
--============================================================================--

local _CLIENT  = _CLIENT

local select   = select
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
		chat:insertText( text .. "\n" )

		-- TODO: Set hide time based on reading-time algorithm.
		-- chat:setHideTime( math.huge )
	end
end
