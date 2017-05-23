--=========== Copyright © 2017, Planimeter, All rights reserved. ===========--
--
-- Purpose: Engine server interface
--
--==========================================================================--

require( "engine.server.network" )
require( "engine.shared.network.payload" )

local payload  = payload
local print    = print
local region   = region
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
	-- Initialize region
	local regionName = _G.game.initialRegion
	region.load( regionName )

	-- Initialize player
	require( "engine.shared.entities.player" )
	local player = _G.player.initialize( event.peer )
	player:setRegion( region.getByName( regionName ) )

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

function sendServerInfo( player )
	local payload = payload( "serverInfo" )
	payload:set( "region", _G.game.initialRegion )
	player:send( payload )
end

shutdown = quit

function upload( filename, peer )
	local payload = payload( "upload" )
	payload:set( "filename", filename )
	payload:set( "file", love.filesystem.read( filename ) )
	peer:send( payload:serialize() )
end
