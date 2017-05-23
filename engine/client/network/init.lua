--=========== Copyright © 2017, Planimeter, All rights reserved. ===========--
--
-- Purpose: Network client interface
--
--==========================================================================--

require( "enet" )

local collectgarbage = collectgarbage
local enet           = enet
local engine         = engine
local string         = string
local type           = type
local print          = print
local require        = require
local _G             = _G

module( "engine.client.network" )

function connect( address )
	if ( not string.find( address, ":" ) ) then
		address = address .. ":26015"
	end

	print( "Connecting to " .. address .. "..." )
	_host = enet.host_create()
	_host:compress_with_range_coder()

	local status, ret = pcall( function()
		return _host:connect( address, 1000 )
	end )
	if ( status ) then
		_server = ret
	else
		print( string.match( ret, ".-: (.+)" ) )
		_host = nil
		collectgarbage()
	end
end

function connectToListenServer()
	require( "engine.client.network.localhost_enet_peer" )
	require( "engine.client.network.localhost_enet_server" )

	_server = _G.localhost_enet_server()
	local event = {
		peer = _G.localhost_enet_peer(),
		type = "connect",
		data = 0,
	}
	engine.server.onConnect( event )

	local event = {
		peer = _server,
		type = "connect",
		data = 0,
	}
	engine.client.onConnect( event )
end

function disconnect()
	if ( not engine.client.isConnected() or
	         engine.client.isDisconnecting() ) then
		return
	end

	print( "Disconnecting from server..." )

	if ( _server ) then
		_server:disconnect()
		_server = nil
	end

	if ( _host ) then
		_host:flush()
		_host = nil
	end

	collectgarbage()

	engine.client.onDisconnect()
end

function sendToServer( data, channel, flag )
	if ( type( data ) == "payload" ) then
		data = data:serialize()
	end
	_server:send( data, channel, flag )
end

local timestep = 1/20
_accumulator   = _accumulator or 0

function update( dt )
	if ( not _host ) then return end

	-- _accumulator = _accumulator + dt

	-- while ( _accumulator >= timestep ) do
		pollEvents()

		-- _accumulator = _accumulator - timestep
	-- end
end

function pollEvents()
	local event = _host:service()
	while ( event ~= nil ) do
		if ( event.type == "connect" ) then
			engine.client.onConnect( event )
		elseif ( event.type == "receive" ) then
			engine.client.onReceive( event )
		elseif ( event.type == "disconnect" ) then
			engine.client.onDisconnect( event )
		end

		if ( host ) then
			event = _host:service()
		else
			event = nil
		end
	end
end
