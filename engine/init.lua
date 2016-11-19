--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Engine interface
--
--============================================================================--

require( "engine.shared.baselib" )
require( "engine.shared.tablib" )
require( "engine.shared.strlib" )
require( "engine.shared.mathlib" )
require( "engine.shared.addon" )
require( "engine.shared.filesystem" )
require( "engine.client.gui" )
require( "engine.shared.region" )

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
		if ( not _CLIENT ) then return end
		local v = engine.client[ k ]
		if ( v ) then return v( ... ) end
	end
end

local addon      = addon
local concommand = concommand
local server     = engine.server
local client     = engine.client
local gui        = gui
local love       = love
local math       = math
local os         = os
local print      = print
local _CLIENT    = _CLIENT
local _SERVER    = _SERVER
local _G         = _G

module( "engine" )

function love.load( arg )
	math.randomseed( os.time() )

	if ( _SERVER ) then server.load( arg ) end
	if ( _CLIENT ) then client.load( arg ) end

	print( "Grid Engine" )

	addon.load( arg )
end

function love.quit()
	if ( _CLIENT and not love._quit ) then
		return g_MainMenu:quit()
	end

	if ( _CLIENT ) then client.disconnect() end
	if ( _SERVER ) then server.quit() end
	if ( _CLIENT ) then client.quit() end

	love.event.quit()
end

concommand( "exit", "Exits the game", function()
	love._quit = true
	love.quit()
end )

local timestep    = 1/33
local accumulator = 0

function love.update( dt )
	if ( _DEBUG ) then love.filesystem.update( dt ) end

	accumulator = accumulator + dt

	while ( accumulator >= timestep ) do
		if ( entity ) then
			local entities = entity.getAll()
			for _, entity in ipairs( entities ) do
				entity:update( timestep )
			end
		end

		if ( _SERVER ) then server.update( timestep ) end
		if ( _CLIENT ) then client.update( timestep ) end

		accumulator = accumulator - timestep
	end

	if ( _CLIENT ) then gui.update( dt ) end
end
