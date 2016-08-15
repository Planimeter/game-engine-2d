--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Network server interface
--
--============================================================================--

-- These values are preserved during real-time scripting.
local network      = engine  and engine.server       and engine.server.network
local _host        = network and network.host        or  nil
local _accumulator = network and network.accumulator or  0
local _peer        = network and network.peer        or  nil

require( "engine.shared.convar" )
require( "engine.shared.hook" )
require( "engine.server.network.host" )

local collectgarbage = collectgarbage
local convar         = convar
local enet           = enet
local hook           = hook
local host           = host
local print          = print
local type           = type
local _G             = _G

local host_ip          = convar( "host_ip", "", nil, nil,
                                 "Host game server ip" )
local host_port        = convar( "host_port", "26015", nil, nil,
                                 "Host game server port" )
local host_max_players = convar( "host_maxplayers", 1000, 0, 1000,
                                 "Host game server max number of players" )

module( "engine.server.network" )

function broadcast( data, channel, flag )
	if ( type( data ) == "payload" ) then
		data = data:serialize()
	end
	_M.host:broadcast( data, channel, flag )
end

_M.host = _host

function initializeServer()
	local host_ip          = host_ip:getValue()
	local host_port        = host_port:getNumber()
	local host_address     = host_ip ~= "" and host_ip .. ":" .. host_port or
	                         "*:" .. host_port
	local host_max_players = host_max_players:getNumber()
	_M.host = host( host_address, host_max_players, 1000 )
	if ( not _M.host:isValid() ) then
		_M.host = nil
		return false
	end

	_M.host:compress_with_range_coder()
	return true
end

function onNetworkInitializedServer()
	if ( _M.host ) then
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

function shutdownServer()
	if ( not _M.host ) then
		return
	end

	print( "Server shutting down..." )
	local peerCount = _G.g_localhost_enet_peer and _M.host:peer_count() - 1 or
	                                               _M.host:peer_count()
	local peer
	for i = 1, peerCount do
		peer = _M.host:get_peer( i )
		peer:disconnect()
	end

	_M.host:flush()
	_M.host = nil
	collectgarbage()
end

timestep    = 1/20
accumulator = _accumulator

function update( dt )
	if ( not _M.host ) then
		return
	end

	-- accumulator = accumulator + dt

	-- while ( accumulator >= timestep ) do
		pollEvents()

		-- accumulator = accumulator - timestep
	-- end
end

peer = _peer

function pollEvents()
	local event = _M.host:service()
	while ( event ~= nil ) do
		if ( event.type == "connect" ) then
			peer = event.peer
			_G.engine.server.onConnect( event )
		elseif ( event.type == "receive" ) then
			_G.engine.server.onReceive( event )
		elseif ( event.type == "disconnect" ) then
			_G.engine.server.onDisconnect( event )
		end

		event = _M.host:service()
	end
end
