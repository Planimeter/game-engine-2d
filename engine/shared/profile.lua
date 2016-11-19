--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Profiling interface
--
--============================================================================--

module( "profile", package.class )

local profiles = {}

function profile.start( name )
	profiles[ name ] = love.timer.getTime()
end

function profile.stop( name )
	local duration = love.timer.getTime() - profiles[ name ]
	print( name .. " took " .. string.format( "%.3fs", duration ) )
end
