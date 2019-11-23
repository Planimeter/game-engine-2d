--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Engine client interface
--
--==========================================================================--

require( "engine.client.bind" )
require( "engine.client.gui" )
require( "engine.shared.network.payload" )

local concommand = concommand
local convar     = convar
local engine     = engine
local gui        = gui
local ipairs     = ipairs
local love       = love
local payload    = payload
local pcall      = pcall
local print      = print
local profile    = profile
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
	local network = engine.client.network
	network.connect( address )
	_connecting = true
end

function connectToListenServer()
	require( "engine.client.network" )
	local network = engine.client.network
	network.connectToListenServer()
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

	local network = engine.client.network
	network.disconnect()
end

concommand( "disconnect", "Disconnects from the server", function()
	disconnect()
end )

function download( filename )
	local payload = payload( "download" )
	payload:set( "filename", filename )
	payload:sendToServer()
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
			local network = engine.server.network
			network.onNetworkInitializedServer()
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
	local payload = payload.initializeFromData( event.data )
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
		local game = _G.game and _G.game.client or nil
		if ( game ) then
			gui._viewportCanvas:remove()
			gui._viewportCanvas = nil
			gui._translucencyCanvas = nil
			game.shutdown()
			unrequire( "game.client" )
			_G.game.client = nil
		end

		-- Shutdown server
		if ( engine.server ) then
			engine.server.shutdown()
			unrequire( "engine.server" )
			engine.server = nil
		end

		-- Shutdown maps
		if ( _G.map ) then
			_G.map.shutdown()
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

function sendClientInfo()
	local payload = payload( "clientInfo" )
	payload:set( "graphicsWidth",  love.graphics.getWidth() )
	payload:set( "graphicsHeight", love.graphics.getHeight() )
	payload:sendToServer()
end

local voice_loopback = convar( "voice_loopback", "0", nil, nil )

function broadcastVoiceRecording()
	local recordingDevice = love.audio.getRecordingDevices()[ 1 ]

	if ( source == nil ) then
		source = love.audio.newQueueableSource( 32000, 16, 1 )
	end

	local data = recordingDevice:getData()
	if ( _voiceRecording and data ) then
		if ( voice_loopback:getBoolean() ) then
			source:queue( data )
			love.audio.play( source )
		end

		local payload = payload( "voice" )
		payload:set( "data", data:getString() )
		payload:broadcast()
	end
end

function sendVoiceRecording()
	local recordingDevice = love.audio.getRecordingDevices()[ 1 ]

	if ( source == nil ) then
		source = love.audio.newQueueableSource( 32000, 16, 1 )
	end

	local data = recordingDevice:getData()
	if ( _voiceRecording and data ) then
		if ( voice_loopback:getBoolean() ) then
			source:queue( data )
			love.audio.play( source )
		end

		local payload = payload( "voice" )
		payload:set( "data", data:getString() )
		payload:sendToServer()
	end
end

function startVoiceRecording()
	local recordingDevice = love.audio.getRecordingDevices()[ 1 ]
	if ( not recordingDevice:isRecording() ) then
		recordingDevice:start( 32768, 32000 )
	end
	_voiceRecording = true
end

function stopVoiceRecording()
	-- BUGBUG: This is expensive.
	-- local recordingDevice = love.audio.getRecordingDevices()[ 1 ]
	-- recordingDevice:stop()
	_voiceRecording = false
end

concommand( "+voice", "Starts recording voice", startVoiceRecording )
concommand( "-voice", "Stops recording voice", stopVoiceRecording )

function tick( timestep )
	local game   = _G.game and _G.game.client or nil
	local entity = _G.entity
	local map    = _G.map

	if ( game == nil ) then
		return
	end

	game.tick( timestep )

	if ( entity ) then
		local entities = entity.getAll()
		for _, entity in ipairs( entities ) do
			entity:tick( timestep )
		end
	end

	map.tick( timestep )

	if ( entity ) then
		local entities = entity.getAll()
		for _, entity in ipairs( entities ) do
			entity:onPostWorldUpdate( timestep )
		end
	end
end
