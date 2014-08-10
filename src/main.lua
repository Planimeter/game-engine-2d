--========= Copyright © 2013-2014, Planimeter, All rights reserved. ==========--
--
-- Purpose: Engine entry point
--
--============================================================================--

_INITTIME = love.timer.getTime()

for i, v in ipairs( arg ) do
	if ( v == "-dedicated" ) then
		_SERVER	   = true
		_DEDICATED = true
	elseif ( v == "-debug" ) then
		_DEBUG = true
	end
end

if ( not _SERVER ) then
	_CLIENT = true
end

_AXIS = false

require( "class" )
require( "engine.shared.require" )
require( "engine" )
