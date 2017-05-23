--=========== Copyright © 2017, Planimeter, All rights reserved. ===========--
--
-- Purpose: Engine client interface
--
--==========================================================================--

require( "engine.client.bind" )
require( "engine.client.graphics" )
require( "engine.client.gui" )
require( "engine.client.sound" )
require( "engine.shared.network.payload" )

local concommand = concommand
local engine     = engine
local gui        = gui
local love       = love
local payload    = payload
local pcall      = pcall
local print      = print
local require    = require
local tostring   = tostring
local unrequire  = unrequire
local _G         = _G

module( "engine.client" )

require( "engine.client.handlers" )
require( "engine.client.payloads" )

function connect( address )
	disconnect()

	require( "engine.client.network" )
	engine.client.network.connect( address )
	connecting = true
end

function connectToListenServer()
	require( "engine.client.network" )
	engine.client.network.connectToListenServer()
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
	if ( engine.client.network ) then engine.client.network.disconnect() end

	connecting = false
	connected  = false

	_G.g_MainMenu:activate()

	if ( _G.entities ) then _G.entities.shutdown() end

	if ( _G.game and _G.game.client ) then
		gui._viewportFramebuffer = nil
		gui._blurFramebuffer = nil
		_G.game.client.shutdown()
		_G.game.client = nil
	end

	if ( _G.region ) then _G.region.shutdown() end

	if ( engine ) then
		if ( engine.server ) then
			engine.server.shutdown()
			engine.server = nil
		end

		if ( _G._SERVER ) then _G._SERVER = nil end
	end
end

concommand( "disconnect", "Disconnects from the server", function()
	disconnect()
end )

function download( filename )
	local payload = payload( "download" )
	payload:set( "filename", filename )
	engine.client.network.sendToServer( payload )
end

function initializeServer()
	if ( _G._SERVER ) then return false end
	if ( connecting ) then return false end

	_G._SERVER = true
	local status, err = pcall( require, "engine.server" )
	if ( status ~= false ) then
		if ( engine.server.load( args ) ) then
			engine.server.network.onNetworkInitializedServer()
		else
			print( "Failed to initialize server!" )
			connecting = false
			connected  = false
			disconnect()
			_G._SERVER = nil
			return false
		end
	else
		_G._SERVER = nil
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
	       _G.game.client and
	       _G.game.client.playerInitialized
end

function onConnect( event )
	connecting = false
	connected  = true
	print( "Connected to server!" )

	_G.hook.call( "client", "onConnect", tostring( event.peer ) )

	-- Prepare to receive entitySpawned payloads
	require( "engine.shared.entities" )
end

function onReceive( event )
	local payload = _G.payload.initializeFromData( event.data )
	payload:setPeer( event.peer )
	payload:dispatchToHandler()
end

function onDisconnect( event )
	if ( connected ) then
		disconnecting = true
		disconnect()
		connected     = false
		disconnecting = false
		_G.hook.call( "client", "onDisconnect" )

		print( "Disconnected from server." )
	else
		connecting = false
		print( "Failed to connect to server!" )
	end

	unrequire( "engine.client.network" )
	engine.client.network = nil
end

function sendClientInfo()
	local payload = payload( "clientInfo" )
	payload:set( "graphicsWidth",  love.graphics.getWidth() )
	payload:set( "graphicsHeight", love.graphics.getHeight() )
	engine.client.network.sendToServer( payload )
end
