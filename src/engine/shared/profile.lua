--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Profiling interface
--
--============================================================================--

local timer  = love.timer
local print  = print
local string = string

module( "profile" )

local profiles = {}

function start( name )
	profiles[ name ] = timer.getTime()
end

local format = string.format

function stop( name )
	local duration = timer.getTime() - profiles[ name ]
	print( name .. " took " .. format( "%.3fs", duration ) )
end
