--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Engine client interface
--
--============================================================================--

-- These values are preserved during real-time scripting.
local _connectedToServer = engine						   and
						   engine.client				   and
						   engine.client.connectedToServer or  false

require( "conf" )
require( "engine.client.graphics" )
require( "engine.client.gui" )
require( "engine.shared.hook" )
require( "engine.shared.network.payload" )

local _AXIS		  = _AXIS

local conf		  = _CONF
local concommand  = concommand
local convar	  = convar
local filesystem  = filesystem
local framebuffer = framebuffer
local graphics	  = graphics
local gui		  = gui
local hook		  = hook
local payload	  = payload
local print		  = print
local require	  = require
local scheme	  = scheme
local string	  = string
local table		  = table
local tostring	  = tostring
local love		  = love
local timer		  = love.timer
local unrequire	  = unrequire
local _G		  = _G

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
end

function connectToListenServer()
	require( "engine.client.network" )
	network = _G.engine.client.network
	_G.networkclient = network
	network.connectToListenServer()
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
	if ( network ) then
		network.disconnect()
	end

	_G.g_MainMenu:activate()

	if ( _G.entities ) then
		_G.entities.shutdown()
	end

	if ( _G.game and _G.game.client ) then
		 _G.game.client.shutdown()
		 _G.game.client = nil
	end

	if ( _G.engine.server ) then
		 _G.engine.server.shutdown()
		 _G.engine.server = nil

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
	network.server:send( payload:serialize() )
end

local perf_draw_frame_rate = convar( "perf_draw_frame_rate", "0", nil, nil,
									 "Draws the frame rate" )

local function drawFrameRate()
	local font	 = scheme.getProperty( "Default", "font" )
	graphics.setFont( font )
	local time	 = getFPS() .. " FPS / " ..
				   string.format( "%.3f", 1000 * getAverageFrameTime() ) .. " ms"
	local height = graphics.getViewportHeight()
	local margin = 96 * ( height / 1080 )
	local x		 = graphics.getViewportWidth() - font:getWidth( time ) - margin
	local y		 = height					   - font:getHeight()	   - margin + 1
	graphics.setColor( scheme.getProperty( "Default", "mainmenubutton.dark.textDropShadowColor" ) )
	graphics.print( time, x, y )
	graphics.setColor( scheme.getProperty( "Default", "mainmenubutton.dark.textColor" ) )
	graphics.print( time, x, y - 1 )
end

function draw()
	if ( isInGame() ) then
		 _G.gameclient.draw()
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

connectedToServer = _connectedToServer

function isConnectedToServer()
	return connectedToServer or _G.engine.server ~= nil
end

function isInGame()
	return isConnectedToServer() and
		   _G.gameclient		 and
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

function textinput( t )
	gui.textinput( t )
end

function keypressed( key, isrepeat )
	-- TODO: Move to bind system!!
	local mainmenu = _G.g_MainMenu
	if ( key == "escape" and mainmenu and isConnectedToServer() ) then
		if ( mainmenu:isVisible() ) then
			mainmenu:close()
		else
			mainmenu:activate()
		end
	end

	-- TODO: Move to bind system!!
	local console = _G.g_Console
	if ( key == "`" and console ) then
		if ( not mainmenu:isVisible() and console:isVisible() ) then
			mainmenu:activate()
			return
		end

		if ( console:isVisible() ) then
			console:close()
		else
			if ( not mainmenu:isVisible() ) then
				mainmenu:activate()
			end
			console:activate()
		end
	end

	if ( gui.keypressed( key, isrepeat ) ) then
		return
	end

	require( "engine.client.bind" )
	_G.bind.keypressed( key, isrepeat )
end

function keyreleased( key )
	if ( gui.keyreleased( key ) ) then
		return
	end

	_G.bind.keyreleased( key )
end

function load( arg )
	_conf = conf

	if ( _G._DEBUG ) then
		perf_draw_frame_rate:setValue( "1" )
	end

	graphics.initialize()
	gui.initialize()
end

function mousepressed( x, y, button )
	if ( gui.mousepressed( x, y, button ) ) then
		return
	end

	require( "engine.client.bind" )
	_G.bind.mousepressed( x, y, button )
end

function mousereleased( x, y, button )
	if ( gui.mousereleased( x, y, button ) ) then
		return
	end

	_G.bind.mousereleased( x, y, button )
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
	connectedToServer = true
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

if ( _G._DEBUG ) then
	cl_payload_show_receive:setValue( "1" )
end

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
	_G.camera.setPosition( localplayer:getPosition() )

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

		_G.gameclient = require( "game.client" )
		_G.gameclient.load( args )

		sendClientInfo()
	end
end

payload.setHandler( onReceiveServerInfo, "serverInfo" )

function onDisconnect( event )
	if ( connectedToServer ) then
		connectedToServer = false
		hook.call( "client", "onDisconnect" )

		print( "Disconnected from server." )
	else
		print( "Failed to connect to server!" )
	end

	unrequire( "engine.client.network" )
	_G.networkclient = nil
	network = nil
end

function reload()
	framebuffer.invalidateFramebuffers()
	gui.invalidateTree()
end

function sendClientInfo()
	local payload = payload( "clientInfo" )
	payload:set( "viewportWidth",  graphics.getViewportWidth() )
	payload:set( "viewportHeight", graphics.getViewportHeight() )
	network.server:send( payload:serialize() )
end

function quit()
end

function update( dt )
	if ( network ) then
		network.update( dt )
	end

	if ( not isInGame() ) then
		graphics.updateGrid()
	end
end
