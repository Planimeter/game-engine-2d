--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Engine server handlers
--
--============================================================================--

module( "engineserver" )

function load( arg )
	local initialized = network.initializeServer()
	if ( not initialized ) then return false end

	require( "game" )

	game.server = require( "game.server" )
	game.server.load( arg )

	return true
end

function quit()
	if ( game and game.server ) then
		 game.server.shutdown()
		 game.server = nil
	end

	unrequire( "game" )
	game = nil

	network.shutdownServer()

	region.unloadAll()

	unrequire( "engine.server.network" )
	network = nil
	unrequire( "engine.server" )
	engine.server = nil
end

function update( dt )
	local regions = region.getAll()
	for _, region in ipairs( regions ) do
		region:update( dt )
	end

	network.update( dt )
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
