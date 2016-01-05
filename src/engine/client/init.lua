--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Engine client interface
--
--============================================================================--

-- These values are preserved during real-time scripting.
local _connected = engine                  and
                   engine.client           and
                   engine.client.connected or  false

require( "conf" )
require( "engine.client.bind" )
require( "engine.client.graphics" )
require( "engine.client.gui" )
require( "engine.shared.hook" )
require( "engine.shared.network.payload" )

local _AXIS       = _AXIS

local bind        = bind
local conf        = _CONF
local concommand  = concommand
local convar      = convar
local filesystem  = filesystem
local framebuffer = framebuffer
local graphics    = graphics
local gui         = gui
local hook        = hook
local payload     = payload
local pcall       = pcall
local print       = print
local require     = require
local scheme      = scheme
local string      = string
local table       = table
local tostring    = tostring
local love        = love
local timer       = love.timer
local unrequire   = unrequire
local _G          = _G

module( "engine.client" )

function connect( address )
	disconnect()

	if ( _AXIS and not isSignedIntoAxis() ) then
		print( "You are not signed into Axis." )
		return
	end

	require( "engine.client.network" )
	network = _G.engine.client.network
	_G.networkclient = network
	network.connect( address )
	connecting = true
end

function connectToListenServer()
	require( "engine.client.network" )
	network = _G.engine.client.network
	_G.networkclient = network
	network.connectToListenServer()
	connecting = true
end

concommand( "connect", "Connects to a server",
	function( _, _, _, argS, argT )
		if ( argT[ 1 ] == nil ) then
			_G.print( "connect <address>" )
			return
		end

		connect( argS )
	end
)

function disconnect()
	-- Check if connected
	if ( not isConnected() ) then
		return
	end

	-- Disconnect from server
	if ( network ) then
		network.disconnect()
	end

	connecting = false
	connected  = false

	-- Activate main menu
	_G.g_MainMenu:activate()

	-- Retrieve subsystems
	local entities = _G.entities
	local game     = _G.game
	local engine   = _G.engine

	-- Shutdown entities
	if ( entities ) then
		entities.shutdown()
	end

	-- Shutdown client game interface
	if ( game ) then
		if ( game.client ) then
			 gui.viewportFramebuffer = nil
			 gui.blurFramebuffer = nil
			 game.client.shutdown()
			 game.client = nil
		end
	end

	-- Shutdown server engine interface
	if ( engine ) then
		if ( engine.server ) then
			 engine.server.shutdown()
			 engine.server = nil
		end

		if ( _G._SERVER ) then
			 _G._SERVER = nil
		end
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

local perf_draw_frame_rate = convar( "perf_draw_frame_rate", "0", nil, nil,
                                     "Draws the frame rate" )

local function drawFrameRate()
	local font   = scheme.getProperty( "Default", "font" )
	graphics.setFont( font )
	local time   = getFPS() .. " FPS / " ..
	               string.format( "%.3f", 1000 * getAverageFrameTime() ) .. " ms"
	local width  = graphics.getViewportWidth()
	local height = graphics.getViewportHeight()
	local margin = gui.scale( 96 )
	local x      = width  - font:getWidth( time ) - margin
	local y      = height - font:getHeight()      - margin + 1
	local color  = scheme.getProperty( "Default", "mainmenubutton.dark.textColor" )
	graphics.setColor( color )
	graphics.print( time, x, y - 1 )
end

local r_draw_grid = convar( "r_draw_grid", "0", nil, nil,
                            "Draws a grid overlay" )

function draw()
	if ( isInGame() ) then
		if ( not gui.viewportFramebuffer ) then
			gui.viewportFramebuffer = graphics.newFullscreenFramebuffer()
		end

		local viewportFramebuffer = gui.viewportFramebuffer
		viewportFramebuffer:clear()
		viewportFramebuffer:renderTo( _G.gameclient.draw )
		viewportFramebuffer:draw()

		if ( r_draw_grid:getBoolean() ) then
			graphics.drawGrid()
		end
	else
		graphics.drawGrid()
	end

	gui.draw()

	if ( perf_draw_frame_rate:getBoolean() ) then
		drawFrameRate()
	end
end

local _focus = nil

function focus( f )
	_focus = f
end

local _getAverageDelta = timer.getAverageDelta

function getAverageFrameTime()
	return _getAverageDelta()
end

local _conf = nil

function getConfig()
	return _conf
end

local _getFPS = timer.getFPS

function getFPS()
	return _getFPS()
end

local _getDelta = timer.getDelta

function getFrameTime()
	return _getDelta()
end

local _getTime = timer.getTime

function getTime()
	return _getTime()
end

function hasFocus()
	if ( _focus ~= nil ) then
		return _focus
	else
		return true
	end
end

function initializeServer()
	local args = _G.engine.getArguments()

	if ( _G._SERVER ) then
		return false
	end

	if ( connecting ) then
		return false
	end

	_G._SERVER = true
	local status, ret = pcall( require, "engine.server" )
	if ( status ~= false ) then
		_G.serverengine = ret
		if ( _G.serverengine.load( args ) ) then
			_G.networkserver.onNetworkInitializedServer()
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
		print( ret )
		return false
	end

	return true
end

connected = _connected

function isConnected()
	return connected or _G.engine.server ~= nil
end

function isDisconnecting()
	return disconnecting
end

function isInGame()
	return isConnected() and
	       _G.gameclient and
	       _G.gameclient.playerInitialized
end

if ( _AXIS ) then
	function isSignedIntoAxis()
		require( "engine.shared.axis" )
		local account = _G.axis.getCurrentUser()
		return account ~= nil
	end
end

function joystickpressed( joystick, button )
	gui.joystickpressed( joystick, button )
end

function joystickreleased( joystick, button )
	gui.joystickreleased( joystick, button )
end

function keypressed( key, scancode, isrepeat )
	require( "engine.client.input" )
	if ( _G.input.isKeyTrapped( key ) ) then
		return
	end

	if ( gui.keypressed( key, scancode, isrepeat ) ) then
		return
	end

	-- TODO: Move to bind system!!
	local mainmenu = _G.g_MainMenu
	if ( key == "escape" and mainmenu and isConnected() ) then
		if ( mainmenu:isVisible() ) then
			mainmenu:close()
		else
			mainmenu:activate()
		end
	end

	bind.keypressed( key, scancode, isrepeat )
end

function keyreleased( key, scancode )
	if ( gui.keyreleased( key, scancode ) ) then
		return
	end

	bind.keyreleased( key, scancode )
end

function load( arg )
	_conf = conf

	graphics.initialize()
	gui.initialize()

	if ( _G._DEBUG ) then
		convar.getConvar( "perf_draw_frame_rate" ):setValue( "1" )
		convar.getConvar( "con_enable" ):setValue( "1" )
	end

	-- TODO: Move to config system!!
	bind.readBinds()
end

function mousepressed( x, y, button, istouch )
	require( "engine.client.input" )
	if ( _G.input.isKeyTrapped( button ) ) then
		return
	end

	if ( gui.mousepressed( x, y, button, istouch ) ) then
		return
	end

	if ( _G.g_MainMenu:isVisible() ) then
		return
	end

	bind.mousepressed( x, y, button, istouch )
end

function mousereleased( x, y, button, istouch )
	if ( gui.mousereleased( x, y, button, istouch ) ) then
		return
	end

	bind.mousereleased( x, y, button, istouch )
end

local sendAuthTicket = nil

if ( _AXIS ) then
	sendAuthTicket = function( server )
		require( "engine.shared.network.payload" )
		require( "engine.shared.axis" )

		local payload = _G.payload( "authenticate" )
		local account = _G.axis.getCurrentUser()
		if ( account ) then
			payload:set( "ticket", account:getTicket() )
			server:send( payload:serialize() )
		end
	end
end

function onConnect( event )
	connecting = false
	connected  = true
	print( "Connected to server!" )

	hook.call( "client", "onConnect", tostring( event.peer ) )

	if ( _AXIS ) then
		local server = event.peer
		sendAuthTicket( server )
	end

	-- Prepare to receive entitySpawned payloads
	require( "engine.shared.entities" )
end

local cl_payload_show_receive = convar( "cl_payload_show_receive", "0", nil, nil,
                                        "Prints payloads received from server" )

function onReceive( event )
	local payload = payload.initializeFromData( event.data )
	payload:setPeer( event.peer )

	if ( cl_payload_show_receive:getBoolean() ) then
		print( "Received payload \"" .. payload:getStructName() .. "\":" )
		table.print( payload:getData(), 1 )
	end

	payload:dispatchToHandler()
end

local function onReceivePlayerInitialized( payload )
	local localplayer = _G.player.getById( payload:get( "id" ) )
	_G.localplayer = localplayer

	_G.g_MainMenu:close()

	require( "engine.client.camera" )
	_G.camera.setParentEntity( localplayer )
	_G.camera.setZoom( 1 )

	if ( not _G._SERVER ) then
		localplayer:initialSpawn()
	end

	_G.gameclient.playerInitialized = true
end

payload.setHandler( onReceivePlayerInitialized, "playerInitialized" )

local function onReceiveServerInfo( payload )
	local regionName = payload:get( "region" )

	require( "engine.shared.region" )
	if ( not _G.region.exists( regionName ) ) then
		download( "regions/" .. regionName .. ".lua" )
	else
		local args = _G.engine.getArguments()

		_G.region.load( regionName )

		require( "game" )

		_G.gameclient = require( "game.client" )
		_G.gameclient.load( args )

		sendClientInfo()
	end
end

payload.setHandler( onReceiveServerInfo, "serverInfo" )

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
	_G.networkclient = nil
	network = nil
end

function reload()
	_G.framebuffer.invalidateFramebuffers()
	gui.invalidateTree()
end

function sendClientInfo()
	local payload = payload( "clientInfo" )
	payload:set( "viewportWidth",  graphics.getViewportWidth() )
	payload:set( "viewportHeight", graphics.getViewportHeight() )
	network.sendToServer( payload )
end

function textinput( t )
	gui.textinput( t )
end

function textedited( text, start, length )
	gui.textedited( text, start, length )
end

function quit()
end

function update( dt )
	if ( _G.gameclient ) then
		_G.gameclient.update( dt )
	end

	if ( network ) then
		network.update( dt )
	end
end

local mx, my = 0, 0
local button = nil

function wheelmoved( x, y )
	require( "engine.client.input" )
	mx, my = _G.input.getMousePosition()
	button = nil
	if ( y < 0 ) then
		button = "wd"
	elseif ( y > 0 ) then
		button = "wu"
	end

	require( "engine.client.input" )
	if ( _G.input.isKeyTrapped( button ) ) then
		return
	end

	if ( gui.wheelmoved( x, y ) ) then
		return
	end

	if ( _G.g_MainMenu:isVisible() ) then
		return
	end

	bind.mousepressed( mx, my, button, false )
end
