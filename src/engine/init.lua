--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Unified engine interface
--
--============================================================================--

-- These values are preserved during real-time scripting.
local engineArgs     = engine and engine.getArguments() or nil
local engineRealTime = engine and engine.getRealTime()  or nil

require( "engine.shared.baselib" )
require( "engine.shared.tablib" )
require( "engine.shared.oslib" )
require( "engine.shared.strlib" )
require( "engine.shared.mathlib" )
require( "engine.shared.filesystem" )
require( "engine.shared.thread" )
require( "engine.shared.convar" )
require( "engine.shared.concommand" )
if ( _CLIENT or _INTERACTIVE ) then
require( "engine.client.gui" )
end
require( "engine.shared.region" )

local _CLIENT      = _CLIENT
local _SERVER      = _SERVER
local _INTERACTIVE = _INTERACTIVE

local concommand   = concommand
local event        = love.event
local gui          = gui
local ipairs       = ipairs
local love         = love
local math         = math
local os           = os
local package      = package
local rawget       = rawget
local require      = require
local setmetatable = setmetatable
local string       = string
local thread       = thread
local timer	       = love.timer
local tostring     = tostring
local type         = type
local _G           = _G

local clientengine
local serverengine

if ( _CLIENT ) then
	clientengine   = require( "engine.client" )
end

if ( _SERVER ) then
	serverengine   = require( "engine.server" )
end

-- Export the interfaces
_G.clientengine    = clientengine
_G.serverengine    = serverengine

module( "engine" )

local metatable = {
	__index = function( table, key )
		if ( type( table ) == "table" ) then
			local v

			if ( _CLIENT ) then
				v = rawget( clientengine, key )
				if ( v ~= nil ) then return v end
			end

			if ( _SERVER ) then
				v = rawget( serverengine, key )
				if ( v ~= nil ) then return v end
			end

			v = rawget( table, key )
			if ( v ~= nil ) then return v end
		end
	end
}
setmetatable( _M, metatable )

client = clientengine
server = serverengine

function draw()
	if ( _CLIENT ) then
		client.draw()
	end

	if ( _INTERACTIVE ) then
		gui.draw()
	end
end

if ( _SERVER ) then
	errhand = server.errhand
end

function focus( f )
	if ( _CLIENT ) then
		client.focus( f )
	end
end

local _arg = engineArgs

function getArguments()
	return _arg
end

local _realtime = engineRealTime

function getRealTime()
	return _realtime
end

function joystickpressed( joystick, button )
	if ( _CLIENT ) then
		client.joystickpressed( joystick, button )
	end
end

function joystickreleased( joystick, button )
	if ( _CLIENT ) then
		client.joystickreleased( joystick, button )
	end
end

function textinput( t )
	if ( _CLIENT ) then
		client.textinput( t )
	end

	if ( _INTERACTIVE ) then
		gui.textinput( t )
	end
end

function keypressed( key, isrepeat )
	if ( _CLIENT ) then
		client.keypressed( key, isrepeat )
	end

	if ( _INTERACTIVE ) then
		gui.keypressed( key, isrepeat )
	end
end

function keyreleased( key )
	if ( _CLIENT ) then
		client.keyreleased( key )
	end

	if ( _INTERACTIVE ) then
		gui.keyreleased( key )
	end
end

function load( arg )
	math.randomseed( os.time() )

	_arg      = arg
	_realtime = 0

	for i, v in ipairs( arg ) do
		if ( v == "-debug" ) then
			_G._DEBUG = true
		end
	end

	if ( _G._SERVER ) then
		server.load( arg )
	end

	if ( _CLIENT ) then
		client.load( arg )
	end

	if ( _INTERACTIVE ) then
		require( "engine.client.graphics" )
		_G.graphics.initialize()
		gui.initialize()
	end

	_G.print( "Grid Engine" )
	local time = string.format( "%.3fs", timer.getTime() - _G._INITTIME )
	_G.print( "All systems go in " .. time )

	_G._INITTIME = nil
end

function mousepressed( x, y, button )
	if ( _CLIENT ) then
		client.mousepressed( x, y, button )
	end

	if ( _INTERACTIVE ) then
		gui.mousepressed( x, y, button )
	end
end

function mousereleased( x, y, button )
	if ( _CLIENT ) then
		client.mousereleased( x, y, button )
	end

	if ( _INTERACTIVE ) then
		gui.mousereleased( x, y, button )
	end
end

local channel = thread.getChannel( "print" )
local v

function processChannels( demand )
	v = demand and channel:demand() or channel:pop()
	if ( v ) then
		_G.print( v )
	end
end

local _isRequestingShutdown = false

function isRequestingShutdown()
	return _isRequestingShutdown
end

function setRequestingShutdown( isRequestingShutdown )
	_isRequestingShutdown = isRequestingShutdown
end

function quit()
	if ( _CLIENT and not isRequestingShutdown() ) then
		_G.g_MainMenu:activate()
		_G.g_MainMenu.closeDialog:activate()
		return true
	end

	if ( _CLIENT ) then
		client.disconnect()
	end

	if ( _G._SERVER ) then
		server.quit()
	end

	if ( _CLIENT ) then
		client.quit()
	end

	event.quit()
end

concommand( "exit", "Exits the game", function()
	setRequestingShutdown( true )
	quit()
end )

function resize( w, h )
	if ( _INTERACTIVE ) then
		_G.g_Console:setSize( w, h )
		_G.framebuffer.invalidateFramebuffers()
		gui.invalidateTree()
	end
end

function threaderror( t, errorstr )
	thread.handleError( t, errorstr )
end

local timestep    = 1/33
local accumulator = 0
local frameTime   = 0

function update( dt )
	if ( _G._DEBUG ) then
		if ( _G._DEDICATED or not client.hasFocus() ) then
			package.update( dt )

			if ( _CLIENT ) then
				_G.image.update( dt )
			end
		end
	end

	_realtime   = _realtime + dt

	frameTime   = dt
	accumulator = accumulator + frameTime

	while ( accumulator >= timestep ) do
		-- Shared engine updates
		if ( _G.entity ) then
			local entities = _G.entity.getAll()
			for _, v in ipairs( entities ) do
				v:update( timestep )
			end
		end

		-- Universe-specific updates
		if ( _G._SERVER ) then
			server.update( timestep )
		end

		if ( _CLIENT ) then
			client.update( timestep )
		end

		accumulator = accumulator - timestep
	end

	if ( _CLIENT or _INTERACTIVE ) then
		gui.update( dt )
	end

	thread.update( dt )
	processChannels()
end

do
	love.draw             = draw

	if ( errhand ) then
		love.errhand      = errhand
	end

	love.focus            = focus
	love.joystickpressed  = joystickpressed
	love.joystickreleased = joystickreleased
	love.textinput        = textinput
	love.keypressed       = keypressed
	love.keyreleased      = keyreleased
	love.load             = load
	love.mousepressed     = mousepressed
	love.mousereleased    = mousereleased
	love.quit             = quit
	love.resize           = resize
	love.threaderror      = threaderror
	love.update           = update
end
