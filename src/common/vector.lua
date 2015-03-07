--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Vector class
--
--============================================================================--

class( "vector" )

function vector.copy( v )
	return vector( v.x, v.y )
end

function vector:vector( x, y )
	self.x = x or 0
	self.y = y or 0
end

function vector:__add( v )
	return vector( self.x + v.x, self.y + v.y )
end

function vector:__eq( v )
	return self.x == v.x and
	       self.y == v.y
end

function vector:__tostring()
	return "vector: (" .. self.x .. ", " .. self.y .. ")"
end

vector.origin = vector()
