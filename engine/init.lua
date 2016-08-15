--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Engine interface
--
--============================================================================--

require( "engine.loader" )

class( "engine" )

function love.load( arg )
	math.randomseed( os.time() )

	if ( _SERVER ) then engineserver.load( arg ) end
	if ( _CLIENT ) then engineclient.load( arg ) end

	print( "Grid Engine" )

	addon.load( arg )
end

function love.quit()
	if ( _CLIENT and not love._quit ) then
		return g_MainMenu:quit()
	end

	if ( _CLIENT ) then engineclient.disconnect() end
	if ( _SERVER ) then engineserver.quit() end
	if ( _CLIENT ) then engineclient.quit() end

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

		if ( _SERVER ) then engineserver.update( timestep ) end
		if ( _CLIENT ) then engineclient.update( timestep ) end

		accumulator = accumulator - timestep
	end

	if ( _CLIENT ) then gui.update( dt ) end
end
