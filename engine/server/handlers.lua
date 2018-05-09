--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: Engine server handlers
--
--==========================================================================--

local debug     = debug
local engine    = engine
local ipairs    = ipairs
local love      = love
local print     = print
local require   = require
local tostring  = tostring
local unrequire = unrequire
local _G        = _G

module( "engine.server" )

function load( arg )
	require( "engine.server.network" )
	local initialized = engine.server.network.initializeServer()
	if ( not initialized ) then
		return false
	end

	_G._SERVER = true

	require( "game" )
	require( "game.server" )
	_G.game.server.load( arg )

	return true
end

function quit()
	-- Shutdown game
	local game = _G.game
	if ( game and game.server ) then
		game.server.shutdown()
		unrequire( "game.server" )
		game.server = nil
	end

	unrequire( "game" )
	_G.game = nil

	-- Shutdown server
	engine.server.network.shutdownServer()

	unrequire( "engine.server.network" )
	engine.server.network = nil
	unrequire( "engine.server.payloads" )
	unrequire( "engine.server.handlers" )

	_G._SERVER = nil
end

function update( dt )
	_G.region.update( dt )

	local game = _G.game and _G.game.server or nil
	if ( game ) then
		game.update( dt )
	end

	local network = engine.server.network
	if ( network ) then
		network.update( dt )
	end
end

local function error_printer(msg, layer)
	print((debug.traceback("Error: " ..
	       tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", "")))
end

function errhand(msg)
	msg = tostring(msg)

	error_printer(msg, 2)

end
