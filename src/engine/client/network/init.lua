--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Network client interface
--
--============================================================================--

-- These values are preserved during real-time scripting.
local network      = engine  and engine.client       and engine.client.network
local _host        = network and network.host        or nil
local _server      = network and network.server      or nil
local _accumulator = network and network.accumulator or 0

require( "enet" )

local collectgarbage = collectgarbage
local enet           = enet
local string         = string
local pcall          = pcall
local print          = print
local require        = require
local type           = type
local _G             = _G

module( "engine.client.network" )

host   = _host
server = _server

function connect( address )
	if ( not string.find( address, ":" ) ) then
		address = address .. ":26015"
	end

	print( "Connecting to " .. address .. "..." )
	host = enet.host_create()
	host:compress_with_range_coder()

	local status, ret = pcall( function()
		return host:connect( address, 1000 )
	end )
	if ( status ) then
		server = ret
	else
		print( string.match( ret, ".-: (.+)" ) )
		host = nil
		collectgarbage()
	end
end

function connectToListenServer()
	require( "engine.client.network.localhost_enet_peer" )
	require( "engine.client.network.localhost_enet_server" )

	server = _G.localhost_enet_server()
	local event = {
		peer = _G.localhost_enet_peer(),
		type = "connect",
		data = 0,
	}
	_G.engine.server.onConnect( event )

	local event = {
		peer = server,
		type = "connect",
		data = 0,
	}
	_G.engine.client.onConnect( event )
end

function disconnect()
	if ( not _G.engine.client.isConnected() ) then
		return
	end

	print( "Disconnecting from server..." )

	if ( server ) then
		server:disconnect()
		server = nil
	end

	if ( host ) then
		host:flush()
		host = nil
	end

	collectgarbage()

	_G.engine.client.onDisconnect()
end

function sendToServer( data, channel, flag )
	if ( type( data ) == "payload" ) then
		data = data:serialize()
	end
	server:send( data, channel, flag )
end

timestep    = 1/20
accumulator = _accumulator

function update( dt )
	if ( not host ) then
		return
	end

	accumulator = accumulator + dt

	while ( accumulator >= timestep ) do
		pollEvents()

		accumulator = accumulator - timestep
	end
end

function pollEvents()
	local event = host:service()
	while ( event ~= nil ) do
		if ( event.type == "connect" ) then
			_G.engine.client.onConnect( event )
		elseif ( event.type == "receive" ) then
			_G.engine.client.onReceive( event )
		elseif ( event.type == "disconnect" ) then
			_G.engine.client.onDisconnect( event )
		end

		if ( host ) then
			event = host:service()
		else
			event = nil
		end
	end
end
