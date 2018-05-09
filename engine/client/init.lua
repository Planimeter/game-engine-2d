--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: Engine client interface
--
--==========================================================================--

require( "engine.client.bind" )
require( "engine.client.gui" )
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
	_connecting = true
end

function connectToListenServer()
	require( "engine.client.network" )
	engine.client.network.connectToListenServer()
	_connecting = true
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
	if ( not isConnected() or isDisconnecting() ) then
		return
	end

	engine.client.network.disconnect()
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
	if ( _G._SERVER ) then
		return false
	end

	if ( _connecting ) then
		return false
	end

	local status, err = pcall( require, "engine.server" )
	if ( status == true ) then
		if ( engine.server.load( args ) ) then
			engine.server.network.onNetworkInitializedServer()
		else
			print( "Failed to initialize server!" )
			_connecting = false
			onDisconnect()
			return false
		end
	else
		print( err )
		return false
	end

	return true
end

_connected = _connected or false

function isConnected()
	return _connected or _G.engine.server ~= nil
end

function isDisconnecting()
	return _disconnecting
end

function isInGame()
	return isConnected()  and
	       _G.localplayer and
	       _G.localplayer._initialized
end

function onConnect( event )
	_connecting = false
	_connected  = true
	print( "Connected to server!" )

	_G.hook.call( "client", "onConnect", tostring( event.peer ) )

	-- Prepare to receive `entitySpawned` payloads
	require( "engine.shared.entities" )
end

function onReceive( event )
	local payload = _G.payload.initializeFromData( event.data )
	payload:setPeer( event.peer )
	payload:dispatchToHandler()
end

function onDisconnect( event )
	if ( _connected or event == nil ) then
		_connecting    = false
		_connected     = false
		_disconnecting = true

		-- Activate main menu
		_G.g_MainMenu:activate()

		-- Remove localplayer
		_G.localplayer = nil

		-- Shutdown entities
		if ( _G.entities ) then
			_G.entities.shutdown()
		end

		-- Shutdown game
		if ( _G.game and _G.game.client ) then
			gui._viewportFramebuffer = nil
			gui._blurFramebuffer = nil
			_G.game.client.shutdown()
			unrequire( "game.client" )
			_G.game.client = nil
		end

		-- Shutdown server
		if ( engine.server ) then
			engine.server.shutdown()
			unrequire( "engine.server" )
			engine.server = nil
		end

		-- Shutdown regions
		if ( _G.region ) then
			_G.region.shutdown()
		end

		_disconnecting = false
		_G.hook.call( "client", "onDisconnect" )

		print( "Disconnected from server." )
	else
		_connecting = false
		print( "Failed to connect to server!" )
	end

	unrequire( "engine.client.network" )
	engine.client.network = nil
end

function onTick( timestep )
	local game = _G.game and _G.game.client or nil
	if ( game ) then
		game.onTick( timestep )
	end
end

function sendClientInfo()
	local payload = payload( "clientInfo" )
	payload:set( "graphicsWidth",  love.graphics.getWidth() )
	payload:set( "graphicsHeight", love.graphics.getHeight() )
	engine.client.network.sendToServer( payload )
end
