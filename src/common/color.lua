--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Color class
--
--============================================================================--

class( "color" )

function color.copy( c )
	return color( c.r, c.g, c.b, c.a )
end

function color:color( r, g, b, a )
	self.r = r or 0
	self.g = g or 0
	self.b = b or 0
	self.a = a or 0
end

function color:__eq( c )
	return self.r == c.r and
	       self.g == c.g and
	       self.b == c.b and
	       self.a == c.a
end

function color:__tostring()
	return "color: (" .. self.r .. ", " ..
	                     self.g .. ", " ..
	                     self.b .. ", " ..
	                     self.a .. ")"
end

color.red   = color( 255,   0,   0, 255 )
color.white = color( 255, 255, 255, 255 )
