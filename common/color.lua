--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Color class
--
--============================================================================--

local type   = type
local unpack = unpack

module( "color", package.class )

function copy( c )
	return _M( unpack( c ) )
end

function _M:color( r, g, b, a )
	if ( type( r ) == "color" ) then
		self[ 1 ] = r[ 1 ] or 0
		self[ 2 ] = r[ 2 ] or 0
		self[ 3 ] = r[ 3 ] or 0
		self[ 4 ] = g      or r[ 4 ] or 0
		return
	end

	self[ 1 ] = r or 0
	self[ 2 ] = g or 0
	self[ 3 ] = b or 0
	self[ 4 ] = a or 0
end

function __eq( a, b )
	return a[ 1 ] == b[ 1 ] and
	       a[ 2 ] == b[ 2 ] and
	       a[ 3 ] == b[ 3 ] and
	       a[ 4 ] == b[ 4 ]
end

function _M:__tostring()
	return "color: ("  ..
		self[ 1 ] .. ", " ..
		self[ 2 ] .. ", " ..
		self[ 3 ] .. ", " ..
		self[ 4 ] ..
	")"
end

red    = _M( 255,   0,   0, 255 )
white  = _M( 255, 255, 255, 255 )
black  = _M(   0,   0,   0, 255 )

client = _M( 168, 168, 123, 255 )
server = _M( 123, 158, 168, 255 )
