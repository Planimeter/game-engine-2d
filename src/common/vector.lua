--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Vector class
--
--============================================================================--

class( "vector" )

function vector:vector( x, y )
	self.x = x or 0
	self.y = y or 0
end

function vector:__eq( b )
	return self.x == b.x and
		   self.y == b.y
end

function vector:__tostring()
	return "vector: (" .. self.x .. ", " .. self.y .. ")"
end

vector.origin = vector()
