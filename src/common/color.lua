--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Color class
--
--============================================================================--

class( "color" )

function color:color( r, g, b, a )
	self.r = r or 0
	self.g = g or 0
	self.b = b or 0
	self.a = a or 0
end

function color:__eq( b )
	return self.r == b.r and
		   self.g == b.g and
		   self.b == b.b and
		   self.a == b.a
end

function color:__tostring()
	return "color: (" .. self.r .. ", " ..
						 self.g .. ", " ..
						 self.b .. ", " ..
						 self.a .. ")"
end

color.red	= color( 255,	0,	 0, 255 )
color.white = color( 255, 255, 255, 255 )
