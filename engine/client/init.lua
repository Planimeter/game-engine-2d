--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Engine client interface
--
--============================================================================--

require( "engine.client.bind" )
require( "engine.client.graphics" )
require( "engine.client.gui" )
require( "engine.client.sound" )
require( "engine.shared.network.payload" )

local require    = require
local concommand = concommand
local _G         = _G

module( "engine.client" )

require( "engine.client.handlers" )
require( "engine.client.payloads" )

function connect( address )
	disconnect()

	require( "engine.client.network" )
	network.connect( address )
	connecting = true
end

function connectToListenServer()
	require( "engine.client.network" )
	network.connectToListenServer()
	connecting = true
end

concommand( "connect", "Connects to a server",
	function( _, _, _, argS, argT )
		if ( argT[ 1 ] == nil ) then
			print( "connect <address>" )
			return
		end

		connect( argS )
	end
)

function disconnect()
	if ( not isConnected() ) then return end
	if ( network ) then network.disconnect() end

	connecting = false
	connected  = false

	g_MainMenu:activate()

	if ( entities ) then entities.shutdown() end

	if ( game and game.client ) then
		gui.viewportFramebuffer = nil
		gui.blurFramebuffer = nil
		game.client.shutdown()
		game.client = nil
	end

	if ( region ) then region.shutdown() end

	if ( engine ) then
		if ( engine.server ) then
			engine.server.shutdown()
			engine.server = nil
		end

		if ( _SERVER ) then _SERVER = nil end
	end
end

concommand( "disconnect", "Disconnects from the server", function()
	disconnect()
end )

function download( filename )
	local payload = payload( "download" )
	payload:set( "filename", filename )
	network.sendToServer( payload )
end

function initializeServer()
	if ( _SERVER ) then return false end
	if ( connecting ) then return false end

	_SERVER = true
	local status, err = pcall( require, "engine.server" )
	if ( status ~= false ) then
		if ( engine.server.load( args ) ) then
			networkserver.onNetworkInitializedServer()
		else
			print( "Failed to initialize server!" )
			connecting = false
			connected  = false
			disconnect()
			_SERVER = nil
			return false
		end
	else
		_SERVER = nil
		print( err )
		return false
	end

	return true
end

connected = false

function isConnected()
	return connected or _G.engine.server ~= nil
end

function isDisconnecting()
	return disconnecting
end

function isInGame()
	return isConnected() and
	       game.client and
	       game.client.playerInitialized
end

function onConnect( event )
	connecting = false
	connected  = true
	print( "Connected to server!" )

	hook.call( "client", "onConnect", tostring( event.peer ) )

	-- Prepare to receive entitySpawned payloads
	require( "engine.shared.entities" )
end

function onReceive( event )
	local payload = payload.initializeFromData( event.data )
	payload:setPeer( event.peer )
	payload:dispatchToHandler()
end

function onDisconnect( event )
	if ( connected ) then
		disconnecting = true
		disconnect()
		connected     = false
		disconnecting = false
		hook.call( "client", "onDisconnect" )

		print( "Disconnected from server." )
	else
		connecting = false
		print( "Failed to connect to server!" )
	end

	unrequire( "engine.client.network" )
	network = nil
end

function sendClientInfo()
	local payload = payload( "clientInfo" )
	payload:set( "graphicsWidth",  love.graphics.getWidth() )
	payload:set( "graphicsHeight", love.graphics.getHeight() )
	network.sendToServer( payload )
end
