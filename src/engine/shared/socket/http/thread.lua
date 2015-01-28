--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Asynchronous HTTP request
--
--============================================================================--

require( "love.filesystem" )
require( "engine.shared.thread" )
require( "engine.shared.tablib" )

local http	   = require( "socket.http" )
local thread   = thread
local channel  = thread.getThreadChannel()
local args	   = channel:pop()
table.raise( args )

local options  = args[ 1 ]
local trequest = false
local t		   = {}
if ( type( options ) == "table" ) then
	trequest = true
	require( "ltn12" )
	options.sink = ltn12.sink.table( t )
end

local result, code, headers, status = http.request( unpack( args ) )
if ( trequest and result == 1 ) then
	result = table.concat( t )
end

channel:push( result )
channel:push( code )
channel:push( headers )
channel:push( status )
