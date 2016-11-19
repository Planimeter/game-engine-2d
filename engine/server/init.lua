--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Engine server interface
--
--============================================================================--

require( "engine.server.network" )
require( "engine.shared.network.payload" )

module( "engineserver" )

require( "engine.server.handlers" )
require( "engine.server.payloads" )

function onConnect( event )
	print( tostring( event.peer ) .. " has connected." )
	onPostConnect( event )
end

function onPostConnect( event )
	-- Initialize region
	local regionName = game.initialRegion
	region.load( regionName )

	-- Initialize player
	require( "engine.shared.entities.player" )
	local player = player.initialize( event.peer )
	player:setRegion( region.getByName( regionName ) )

	player:onConnect()

	-- Set spawn point
	local spawnPoint = gameserver.getSpawnPoint( player )
	local position = vector.origin + vector( 0, game.tileSize )
	if ( spawnPoint ) then
		position = spawnPoint:getPosition()
	end
	player:setNetworkVar( "position", position )

	-- Send server info
	sendServerInfo( player )
end

function onReceive( event )
	local payload = payload.initializeFromData( event.data )
	payload:setPeer( event.peer )
	payload:dispatchToHandler()
end

function onDisconnect( event )
	local player = player.getByPeer( event.peer )
	if ( player ) then
		player:onDisconnect()
		player:remove()
	end

	print( tostring( event.peer ) .. " has disconnected." )
end

function sendServerInfo( player )
	local payload = payload( "serverInfo" )
	payload:set( "region", game.initialRegion )
	player:send( payload )
end

shutdown = quit

function upload( filename, peer )
	local payload = payload( "upload" )
	payload:set( "filename", filename )
	payload:set( "file", love.filesystem.read( filename ) )
	peer:send( payload:serialize() )
end
