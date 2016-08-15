--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Engine client interface
--
--============================================================================--

require( "engine.client.bind" )
require( "engine.client.graphics" )
require( "engine.client.gui" )
require( "engine.client.sound" )
require( "engine.shared.hook" )
require( "engine.shared.network.payload" )

class( "engineclient" )

dofile( "engine/client/handlers.lua" )
dofile( "engine/client/payloads.lua" )

function engineclient.connect( address )
	engineclient.disconnect()

	require( "engine.client.network" )
	networkclient.connect( address )
	engineclient.connecting = true
end

function engineclient.connectToListenServer()
	require( "engine.client.network" )
	networkclient.connectToListenServer()
	engineclient.connecting = true
end

concommand( "connect", "Connects to a server",
	function( _, _, _, argS, argT )
		if ( argT[ 1 ] == nil ) then
			print( "connect <address>" )
			return
		end

		engineclient.connect( argS )
	end
)

function engineclient.disconnect()
	if ( not engineclient.isConnected() ) then return end
	if ( networkclient ) then networkclient.disconnect() end

	engineclient.connecting = false
	engineclient.connected  = false

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
		if ( engineserver ) then
			engineserver.shutdown()
			engineserver = nil
		end

		if ( _SERVER ) then _SERVER = nil end
	end
end

concommand( "disconnect", "Disconnects from the server", function()
	engineclient.disconnect()
end )

function engineclient.download( filename )
	local payload = payload( "download" )
	payload:set( "filename", filename )
	networkclient.sendToServer( payload )
end

function engineclient.initializeServer()
	if ( _SERVER ) then return false end
	if ( engineclient.connecting ) then return false end

	_SERVER = true
	local status, err = pcall( require, "engine.server" )
	if ( status ~= false ) then
		if ( engineserver.load( args ) ) then
			networkserver.onNetworkInitializedServer()
		else
			print( "Failed to initialize server!" )
			engineclient.connecting = false
			engineclient.connected  = false
			engineclient.disconnect()
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

engineclient.connected = false

function engineclient.isConnected()
	return engineclient.connected or engineserver ~= nil
end

function engineclient.isDisconnecting()
	return engineclient.disconnecting
end

function engineclient.isInGame()
	return engineclient.isConnected() and
	       gameclient and
	       gameclient.playerInitialized
end

function engineclient.onConnect( event )
	engineclient.connecting = false
	engineclient.connected  = true
	print( "Connected to server!" )

	hook.call( "client", "onConnect", tostring( event.peer ) )

	-- Prepare to receive entitySpawned payloads
	require( "engine.shared.entities" )
end

function engineclient.onReceive( event )
	local payload = payload.initializeFromData( event.data )
	payload:setPeer( event.peer )
	payload:dispatchToHandler()
end

function engineclient.onDisconnect( event )
	if ( engineclient.connected ) then
		engineclient.disconnecting = true
		engineclient.disconnect()
		engineclient.connected     = false
		engineclient.disconnecting = false
		hook.call( "client", "onDisconnect" )

		print( "Disconnected from server." )
	else
		engineclient.connecting = false
		print( "Failed to connect to server!" )
	end

	unrequire( "engine.client.network" )
	networkclient = nil
end

function engineclient.sendClientInfo()
	local payload = payload( "clientInfo" )
	payload:set( "graphicsWidth",  love.graphics.getWidth() )
	payload:set( "graphicsHeight", love.graphics.getHeight() )
	networkclient.sendToServer( payload )
end
