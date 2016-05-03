--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Physics interface
--
--============================================================================--

require( "love.physics" )

local physics = love.physics

module( "physics" )

function newBody( world, x, y, type )
	return physics.newBody( world, x, y, type )
end

function newFixture( body, shape, density )
	return physics.newFixture( body, shape, density )
end

function newRectangleShape( ... )
	return physics.newRectangleShape( ... )
end

function newWorld( xg, yg, sleep )
	return physics.newWorld( xg, yg, sleep )
end
