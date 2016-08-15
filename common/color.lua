--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Color class
--
--============================================================================--

class( "color" )

function color.copy( c )
	return color( c.r, c.g, c.b, c.a )
end

function color:color( r, g, b, a )
	if ( type( r ) == "color" ) then
		self.r = r.r or 0
		self.g = r.g or 0
		self.b = r.b or 0
		self.a = g   or r.a or 0
		return
	end

	self.r = r or 0
	self.g = g or 0
	self.b = b or 0
	self.a = a or 0
end

function color.__eq( a, b )
	return a.r == b.r and
	       a.g == b.g and
	       a.b == b.b and
	       a.a == b.a
end

function color:__tostring()
	return "color: ("  ..
		self.r .. ", " ..
		self.g .. ", " ..
		self.b .. ", " ..
		self.a ..
	")"
end

color.red    = color( 255,   0,   0, 255 )
color.white  = color( 255, 255, 255, 255 )
color.black  = color(   0,   0,   0, 255 )

color.client = color( 168, 168, 123, 255 )
color.server = color( 123, 158, 168, 255 )
