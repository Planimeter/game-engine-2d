--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Engine server handlers
--
--============================================================================--

function engineserver.load( arg )
	local initialized = networkserver.initializeServer()
	if ( not initialized ) then return false end

	require( "game" )

	gameserver = require( "game.server" )
	gameserver.load( arg )

	return true
end

function engineserver.quit()
	if ( game and game.server ) then
		 game.server.shutdown()
		 game.server = nil
	end

	unrequire( "game" )
	game = nil

	networkserver.shutdownServer()

	region.unloadAll()

	unrequire( "engine.server.network" )
	networkserver = nil
	unrequire( "engine.server" )
	engineserver = nil
end

function engineserver.update( dt )
	local regions = region.getAll()
	for _, region in ipairs( regions ) do
		region:update( dt )
	end

	networkserver.update( dt )
end

local function error_printer(msg, layer)
	print((debug.traceback("Error: " ..
	       tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", "")))
end

function engineserver.errhand(msg)
	msg = tostring(msg)

	error_printer(msg, 2)

	while true do
		if love.timer then
			love.timer.sleep(0.1)
		end
	end

end
