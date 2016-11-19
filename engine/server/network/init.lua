--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Network server interface
--
--============================================================================--

require( "engine.shared.convar" )
require( "engine.server.network.host" )

local host_ip          = convar( "host_ip", "", nil, nil,
                                 "Host game server ip" )
local host_port        = convar( "host_port", "26015", nil, nil,
                                 "Host game server port" )
local host_max_players = convar( "host_maxplayers", 1000, 0, 1000,
                                 "Host game server max number of players" )

module( "networkserver", package.class )

function networkserver.broadcast( data, channel, flag )
	if ( type( data ) == "payload" ) then
		data = data:serialize()
	end
	networkserver.host:broadcast( data, channel, flag )
end

function networkserver.initializeServer()
	local host_ip          = host_ip:getValue()
	local host_port        = host_port:getNumber()
	local host_address     = host_ip ~= "" and host_ip .. ":" .. host_port or
	                         "*:" .. host_port
	local host_max_players = host_max_players:getNumber()
	networkserver.host = host( host_address, host_max_players, 1000 )
	if ( not networkserver.host:isValid() ) then
		networkserver.host = nil
		return false
	end

	networkserver.host:compress_with_range_coder()
	return true
end

function networkserver.onNetworkInitializedServer()
	if ( networkserver.host ) then
		local host_ip          = host_ip:getValue()
		local host_port        = host_port:getNumber()
		local host_address     = host_ip ~= "" and host_ip .. ":" .. host_port or
		                         "*:" .. host_port
		local host_max_players = host_max_players:getNumber()
		print( "Server initialized at " .. host_address .. " for " ..
		       host_max_players .. " players..." )
	else
		print( "Failed to initialize server!" )
	end
end

function networkserver.shutdownServer()
	if ( not networkserver.host ) then return end

	print( "Server shutting down..." )
	local peerCount = g_localhost_enet_peer and networkserver.host:peer_count() - 1 or
	                                            networkserver.host:peer_count()
	for i = 1, peerCount do
		local peer = networkserver.host:get_peer( i )
		peer:disconnect()
	end

	networkserver.host:flush()
	networkserver.host = nil
	collectgarbage()
end

local timestep    = 1/20
local accumulator = _accumulator

function networkserver.update( dt )
	if ( not networkserver.host ) then return end

	-- accumulator = accumulator + dt

	-- while ( accumulator >= timestep ) do
		networkserver.pollEvents()

		-- accumulator = accumulator - timestep
	-- end
end

function networkserver.pollEvents()
	local event = networkserver.host:service()
	while ( event ~= nil ) do
		if ( event.type == "connect" ) then
			peer = event.peer
			engine.server.onConnect( event )
		elseif ( event.type == "receive" ) then
			engine.server.onReceive( event )
		elseif ( event.type == "disconnect" ) then
			engine.server.onDisconnect( event )
		end

		event = networkserver.host:service()
	end
end
