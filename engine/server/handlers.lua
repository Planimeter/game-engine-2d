--=========== Copyright © 2017, Planimeter, All rights reserved. ===========--
--
-- Purpose: Engine server handlers
--
--==========================================================================--

local engine    = engine
local ipairs    = ipairs
local require   = require
local unrequire = unrequire
local _G        = _G

module( "engine.server" )

function load( arg )
	local initialized = engine.server.network.initializeServer()
	if ( not initialized ) then return false end

	require( "game" )

	require( "game.server" )
	_G.game.server.load( arg )

	return true
end

function quit()
	local game = _G.game
	if ( game ) then
		 game.server.shutdown()
		 game.server = nil
	end

	unrequire( "game" )
	_G.game = nil

	engine.server.network.shutdownServer()

	_G.region.unloadAll()

	unrequire( "engine.server.network" )
	engine.server.network = nil
	unrequire( "engine.server.payloads" )
	unrequire( "engine.server.handlers" )
	unrequire( "engine.server" )
	engine.server = nil
end

function update( dt )
	local regions = _G.region.getAll()
	for _, region in ipairs( regions ) do
		region:update( dt )
	end

	engine.server.network.update( dt )
end

local function error_printer(msg, layer)
	print((debug.traceback("Error: " ..
	       tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", "")))
end

function errhand(msg)
	msg = tostring(msg)

	error_printer(msg, 2)

	while true do
		if love.timer then
			love.timer.sleep(0.1)
		end
	end

end
