--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Network client interface
--
--============================================================================--

require( "enet" )

class( "networkclient" )

networkclient.host   = _host
networkclient.server = _server

function networkclient.connect( address )
	if ( not string.find( address, ":" ) ) then
		address = address .. ":26015"
	end

	print( "Connecting to " .. address .. "..." )
	networkclient.host = enet.host_create()
	networkclient.host:compress_with_range_coder()

	local status, ret = pcall( function()
		return networkclient.host:connect( address, 1000 )
	end )
	if ( status ) then
		server = ret
	else
		print( string.match( ret, ".-: (.+)" ) )
		networkclient.host = nil
		collectgarbage()
	end
end

function networkclient.connectToListenServer()
	require( "engine.client.network.localhost_enet_peer" )
	require( "engine.client.network.localhost_enet_server" )

	networkclient.server = _G.localhost_enet_server()
	local event = {
		peer = _G.localhost_enet_peer(),
		type = "connect",
		data = 0,
	}
	engineserver.onConnect( event )

	local event = {
		peer = server,
		type = "connect",
		data = 0,
	}
	engineclient.onConnect( event )
end

function networkclient.disconnect()
	if ( not engineclient.isConnected() or
	         engineclient.isDisconnecting() ) then
		return
	end

	print( "Disconnecting from server..." )

	if ( networkclient.server ) then
		networkclient.server:disconnect()
		networkclient.server = nil
	end

	if ( networkclient.host ) then
		networkclient.host:flush()
		networkclient.host = nil
	end

	collectgarbage()

	engineclient.onDisconnect()
end

function networkclient.sendToServer( data, channel, flag )
	if ( type( data ) == "payload" ) then
		data = data:serialize()
	end
	networkclient.server:send( data, channel, flag )
end

local timestep    = 1/20
local accumulator = _accumulator

function networkclient.update( dt )
	if ( not networkclient.host ) then return end

	-- accumulator = accumulator + dt

	-- while ( accumulator >= timestep ) do
		pollEvents()

		-- accumulator = accumulator - timestep
	-- end
end

function networkclient.pollEvents()
	local event = networkclient.host:service()
	while ( event ~= nil ) do
		if ( event.type == "connect" ) then
			engineclient.onConnect( event )
		elseif ( event.type == "receive" ) then
			engineclient.onReceive( event )
		elseif ( event.type == "disconnect" ) then
			engineclient.onDisconnect( event )
		end

		if ( host ) then
			event = host:service()
		else
			event = nil
		end
	end
end
