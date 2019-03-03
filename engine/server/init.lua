--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: Engine server interface
--
--==========================================================================--

require( "engine.shared.network.payload" )

local payload  = payload
local print    = print
local map      = map
local require  = require
local tostring = tostring
local _G       = _G

module( "engine.server" )

require( "engine.server.handlers" )
require( "engine.server.payloads" )

function onConnect( event )
	print( tostring( event.peer ) .. " has connected." )
	onPostConnect( event )
end

function onPostConnect( event )
	-- Initialize map
	local mapName = _G.game.initialMap
	require( "engine.shared.map" )
	_G.map.load( mapName )

	-- Initialize player
	require( "engine.shared.entities" )
	_G.entities.require( "player" )
	local player = _G.player.initialize( event.peer )
	player:setMap( _G.map.getByName( mapName ) )

	player:onConnect()

	-- Set spawn point
	local spawnPoint = _G.game.server.getSpawnPoint( player )
	local position = _G.vector.origin + _G.vector( 0, _G.game.tileSize )
	if ( spawnPoint ) then
		position = spawnPoint:getPosition()
	end
	player:setNetworkVar( "position", position )

	-- Send server info
	sendServerInfo( player )
end

function onReceive( event )
	local payload = _G.payload.initializeFromData( event.data )
	payload:setPeer( event.peer )
	payload:dispatchToHandler()
end

function onDisconnect( event )
	local player = _G.player.getByPeer( event.peer )
	if ( player ) then
		player:onDisconnect()
		player:remove()
	end

	print( tostring( event.peer ) .. " has disconnected." )
end

function onTick( timestep )
	local game = _G.game and _G.game.server or nil
	if ( game ) then
		game.onTick( timestep )
	end
end

function sendServerInfo( player )
	local payload = payload( "serverInfo" )
	payload:set( "map", _G.game.initialMap )
	player:send( payload )
end

shutdown = quit

function upload( filename, peer )
	local payload = payload( "upload" )
	payload:set( "filename", filename )
	payload:set( "file", love.filesystem.read( filename ) )
	peer:send( payload:serialize() )
end
