--=========== Copyright © 2017, Planimeter, All rights reserved. ===========--
--
-- Purpose: Network server interface
--
--==========================================================================--

require( "engine.shared.convar" )
require( "engine.server.network.host" )

local host_ip          = convar( "host_ip", "", nil, nil,
                                 "Host game server ip" )
local host_port        = convar( "host_port", "26015", nil, nil,
                                 "Host game server port" )
local host_max_players = convar( "host_maxplayers", 1000, 0, 1000,
                                 "Host game server max number of players" )

local collectgarbage = collectgarbage
local engine         = engine
local print          = print
local type           = type
local _G             = _G

module( "engine.server.network" )

function broadcast( data, channel, flag )
	if ( type( data ) == "payload" ) then
		data = data:serialize()
	end
	_host:broadcast( data, channel, flag )
end

function initializeServer()
	local ip          = host_ip:getValue()
	local port        = host_port:getNumber()
	local address     = ip ~= "" and ip .. ":" .. port or "*:" .. port
	local max_players = host_max_players:getNumber()
	_host = _G.host( address, max_players, 1000 )
	if ( not _host:isValid() ) then
		_host = nil
		return false
	end

	_host:compress_with_range_coder()
	return true
end

function onNetworkInitializedServer()
	if ( _host ) then
		local ip          = host_ip:getValue()
		local port        = host_port:getNumber()
		local address     = ip ~= "" and ip .. ":" .. port or "*:" .. port
		local max_players = host_max_players:getNumber()
		print( "Server initialized at " .. address .. " for " ..
		       max_players .. " players..." )
	else
		print( "Failed to initialize server!" )
	end
end

function shutdownServer()
	if ( not _host ) then
		return
	end

	print( "Server shutting down..." )
	local peerCount = g_localhost_enet_peer and _host:peer_count() - 1 or
	                                            _host:peer_count()
	for i = 1, peerCount do
		local peer = _host:get_peer( i )
		peer:disconnect()
	end

	_host:flush()
	_host = nil
	collectgarbage()
end

local timestep = 1/20
_accumulator   = _accumulator or 0

function update( dt )
	if ( not _host ) then
		return
	end

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
			peer = event.peer
			engine.server.onConnect( event )
		elseif ( event.type == "receive" ) then
			engine.server.onReceive( event )
		elseif ( event.type == "disconnect" ) then
			engine.server.onDisconnect( event )
		end

		event = _host:service()
	end
end
