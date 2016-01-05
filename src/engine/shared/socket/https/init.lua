--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Asynchronous HTTPS interface
--
--============================================================================--

require( "engine.shared.thread" )

local table  = table
local thread = thread
local unpack = unpack

module( "https" )

function request( reqt, body, callback )
	local threadCallback = function( channel )
		local args = {}
		for i = 1, channel:getCount() do
			table.insert( args, channel:pop() )
		end
		if ( callback ) then
			callback( unpack( args ) )
		end
	end
	local thread, channel = thread.newThreadedTask(
		"engine/shared/socket/https/thread.lua",
		threadCallback
	)

	local args = { reqt, body }
	table.flatten( args )
	channel:push( args )
	thread:start()
end
