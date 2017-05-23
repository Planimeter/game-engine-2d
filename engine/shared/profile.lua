--=========== Copyright © 2017, Planimeter, All rights reserved. ===========--
--
-- Purpose: Profiling interface
--
--==========================================================================--

class( "profile" )

local profiles = {}

function profile.start( name )
	profiles[ name ] = love.timer.getTime()
end

function profile.stop( name )
	local duration = love.timer.getTime() - profiles[ name ]
	print( name .. " took " .. string.format( "%.3fs", duration ) )
end
