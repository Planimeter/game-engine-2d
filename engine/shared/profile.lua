--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: Profiling interface
--
--==========================================================================--

class( "profile" )

profile._profiles = profile._profiles or {}

function profile.start( name )
	profile._profiles[ name ] = love.timer.getTime()
end

function profile.stop( name )
	local duration = love.timer.getTime() - profile._profiles[ name ]
	print( name .. " took " .. string.format( "%.3fs", duration ) )
end
