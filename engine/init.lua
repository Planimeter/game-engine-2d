--=========== Copyright © 2017, Planimeter, All rights reserved. ===========--
--
-- Purpose: Engine interface
--
--==========================================================================--

require( "engine.shared.baselib" )
require( "engine.shared.tablib" )
require( "engine.shared.strlib" )
require( "engine.shared.mathlib" )

if ( _CLIENT ) then
	require( "engine.client.graphics" )
	require( "engine.client.gui" )
end

local engine     = engine or {}
_G.engine        = engine

local concommand = concommand
local gui        = gui
local ipairs     = ipairs
local love       = love
local math       = math
local os         = os
local package    = package
local pairs      = pairs
local print      = print
local require    = require
local _DEBUG     = _DEBUG
local _CLIENT    = _CLIENT
local _SERVER    = _SERVER
local _G         = _G

module( "engine" )

if ( _CLIENT ) then
	require( "engine.client" )
	love.draw = engine.client.draw
end

if ( _SERVER ) then
	require( "engine.server" )
	love.errhand = engine.server.errhand
end

-- Standard callback handlers
for k in pairs( love.handlers ) do
	love[ k ] = function( ... )
		if ( not _CLIENT ) then
			return
		end

		local v = engine.client[ k ]
		if ( v ) then
			return v( ... )
		end
	end
end

function love.focus( focus )
	if ( focus ) then
		local dt = love.timer.getDelta()
		if ( _DEBUG ) then
			package.update( dt )

			if ( _G.sound ) then
				_G.sound.update( dt )
			end
		end
	end

	if ( not _CLIENT ) then
		return
	end

	local v = engine.client[ "focus" ]
	if ( v ) then
		return v( focus )
	end
end

function love.load( arg )
	math.randomseed( os.time() )

	if ( _SERVER ) then
		engine.server.load( arg )
	end

	if ( _CLIENT ) then
		engine.client.load( arg )
	end

	print( "Grid Engine" )

	require( "engine.shared.addon" )
	_G.addon.load( arg )

	require( "engine.shared.region" )
end

function love.quit()
	if ( _CLIENT and not love._shouldQuit ) then
		return _G.g_MainMenu:quit()
	end

	if ( _CLIENT ) then
		engine.client.disconnect()
	end

	if ( _SERVER ) then
		engine.server.quit()
	end

	if ( _CLIENT ) then
		engine.client.quit()
	end

	love.event.quit()
end

concommand( "exit", "Exits the game", function()
	love._shouldQuit = true
	love.quit()
end )

local timestep    = 1/33
local accumulator = 0

function love.update( dt )
	if ( _DEBUG and _DEDICATED ) then
		package.update( dt )
	end

	accumulator = accumulator + dt

	while ( accumulator >= timestep ) do
		local entity  = _G.entity
		local _CLIENT = _CLIENT
		local _SERVER = _SERVER or _G._SERVER

		if ( entity ) then
			local entities = entity.getAll()
			for _, entity in ipairs( entities ) do
				entity:update( timestep )
			end
		end

		if ( _SERVER ) then
			engine.server.update( timestep )
		end

		if ( _CLIENT ) then
			engine.client.update( timestep )
		end

		accumulator = accumulator - timestep
	end

	if ( _CLIENT ) then
		gui.update( dt )
	end
end
