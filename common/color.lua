--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Color class
--
--==========================================================================--

class( "color" )

function color.copy( c )
	return color( unpack( c ) )
end

function color:color( r, g, b, a )
	if ( type( r ) == "color" ) then
		self[ 1 ] = r[ 1 ]  or 0
		self[ 2 ] = r[ 2 ]  or 0
		self[ 3 ] = r[ 3 ]  or 0
		self[ 4 ] = g and g / 255 or ( r[ 4 ] or 0 )
		return
	end

	self[ 1 ] = r / 255 or 0
	self[ 2 ] = g / 255 or 0
	self[ 3 ] = b / 255 or 0
	self[ 4 ] = a / 255 or 0
end

function color.__eq( a, b )
	return a[ 1 ] == b[ 1 ] and
	       a[ 2 ] == b[ 2 ] and
	       a[ 3 ] == b[ 3 ] and
	       a[ 4 ] == b[ 4 ]
end

function color:__tostring()
	return "color: ("  ..
		self[ 1 ] .. ", " ..
		self[ 2 ] .. ", " ..
		self[ 3 ] .. ", " ..
		self[ 4 ] ..
	")"
end

color.transparent = color(   0,   0,   0,   0 )
color.white       = color( 255, 255, 255, 255 )
color.black       = color(   0,   0,   0, 255 )
color.red         = color( 255,   0,   0, 255 )

color.client      = color( 168, 168, 123, 255 )
color.server      = color( 123, 158, 168, 255 )

color.margin      = color( 235, 179, 116, 167 )
color.padding     = color( 157, 194, 132, 167 )
color.content     = color( 122, 168, 215, 167 )
