--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
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

local arg        = arg
local concommand = concommand
local convar     = convar
local gui        = gui
local ipairs     = ipairs
local love       = love
local math       = math
local os         = os
local package    = package
local pairs      = pairs
local print      = print
local profile    = profile
local require    = require
local string     = string
local table      = table
local _DEBUG     = _DEBUG
local _CLIENT    = _CLIENT
local _SERVER    = _SERVER
local _DEDICATED = _DEDICATED
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

-- local fps_max = convar( "fps_max", "300", nil, nil, "Frame rate limiter" )
--
-- function love.run()
-- 	if love.load then love.load(love.arg.parseGameArguments(arg), arg) end
--
-- 	-- We don't want the first frame's dt to include time taken by love.load.
-- 	if love.timer then love.timer.step() end
--
-- 	-- Main loop time.
-- 	return function()
-- 		engine.run()
-- 	end
--
-- end
--
-- function run()
-- 	local dt = 0
-- 	local startTime = 0
-- 	local endTime = 0
-- 	local duration = 0
-- 	local remaining = 0
--
-- 	if love.timer then startTime = love.timer.getTime() end
--
-- 	-- Process events.
-- 	if love.event then
-- 		love.event.pump()
-- 		for name, a,b,c,d,e,f in love.event.poll() do
-- 			if name == "quit" then
-- 				if not love.quit or not love.quit() then
-- 					return a or 0
-- 				end
-- 			end
-- 			love.handlers[name](a,b,c,d,e,f)
-- 		end
-- 	end
--
-- 	-- Update dt, as we'll be passing it to update
-- 	if love.timer then dt = love.timer.step() end
--
-- 	-- Call update and draw
-- 	if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled
--
-- 	if love.graphics and love.graphics.isActive() then
-- 		profile.push( "draw" )
-- 		love.graphics.origin()
-- 		love.graphics.clear(love.graphics.getBackgroundColor())
--
-- 		if love.draw then love.draw() end
-- 		profile.pop( "draw" )
--
-- 		profile.push( "present" )
-- 		love.graphics.present()
-- 		profile.pop( "present" )
-- 	end
--
-- 	if love.timer then endTime = love.timer.getTime() end
-- 	duration = endTime - startTime
-- 	remaining = math.max( 0, 1 / fps_max:getNumber() - duration )
-- 	if love.timer and remaining > 0 then love.timer.sleep(remaining) end
-- end

function love.focus( focus )
	if ( focus ) then
		local dt = love.timer.getDelta()
		if ( _DEBUG ) then
			package.update( dt )

			if ( _G.source ) then
				_G.source.update( dt )
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

	if ( _CLIENT ) then
		engine.client.load( arg )
	end

	if ( _SERVER ) then
		engine.server.load( arg )
	end

	print( "Grid Engine [Version 9]" )
	print( "© 2019 Planimeter. All rights reserved.\r\n" )

	require( "engine.shared.addon" )
	_G.addon.load( arg )

	require( "engine.shared.map" )

	if ( _CLIENT ) then
		table.foreachi( arg, function( i, v )
			local name = string.match( v, "^%+(.-)$" )
			if ( name == nil ) then
				return
			end

			concommand.run( name .. " " .. arg[ i + 1 ] )
		end )
	end

	profile.pop( "load" )
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

local host_timescale = convar( "host_timescale", "1", nil, nil,
                               "Prescales the clock by this amount" )

function love.update( dt )
	profile.push( "update" )

	dt = host_timescale:getNumber() * dt
	if ( _DEBUG and _DEDICATED ) then
		package.update( dt )
	end

	local _CLIENT = _CLIENT
	local _SERVER = _SERVER or _G._SERVER

	if ( _CLIENT ) then
		engine.client.update( dt )
	end

	if ( _SERVER ) then
		engine.server.update( dt )
	end

	if ( _CLIENT ) then
		gui.update( dt )
	end

	profile.pop( "update" )
end
