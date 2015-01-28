--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Asynchronous HTTP interface
--
--============================================================================--

require( "engine.shared.thread" )

local pairs	   = pairs
local require  = require
local table	   = table
local thread   = thread
local tostring = tostring
local type	   = type
local unpack   = unpack

module( "http" )

local url	 = require( "socket.url" )
local escape = url.escape

function urlencode( t )
	if ( type( t ) == "string" ) then
		return escape( t )
	end

	local query = {}
	for k, v in pairs( t ) do
		table.insert( query, k .. "=" .. escape( tostring( v ) ) )
	end
	return table.concat( query, "&" )
end

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
		"engine/shared/socket/http/thread.lua",
		threadCallback
	)

	local args = { reqt, body }
	table.flatten( args )
	channel:push( args )
	thread:start()
end
