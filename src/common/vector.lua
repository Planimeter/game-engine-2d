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

local sqrt = math.sqrt

function vector:length()
	return sqrt( self.x ^ 2 + self.y ^ 2 )
end

function vector:lengthSqr()
	return self.x ^ 2 + self.y ^ 2
end

local length = 0

function vector:normalize()
	length = self:length()
	return vector( self.x / length, self.y / length )
end

function vector:normalizeInPlace()
	length = self:length()
	self.x = length == 0 and 0 or self.x / length
	self.y = length == 0 and 0 or self.y / length
end

function vector:__add( v )
	return vector( self.x + v.x, self.y + v.y )
end

function vector:__sub( v )
	return vector( self.x - v.x, self.y - v.y )
end

function vector:__mul( v )
	if ( type( v ) == "number" ) then
		return vector( v * self.x, v * self.y )
	else
		return vector( self.x * v.x, self.y * v.y )
	end
end

function vector:__eq( v )
	return self.x == v.x and
	       self.y == v.y
end

function vector:__tostring()
	return "vector: (" .. self.x .. ", " .. self.y .. ")"
end

vector.origin = vector()
