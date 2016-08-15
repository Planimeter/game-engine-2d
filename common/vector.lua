--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
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

function vector:length()
	return math.sqrt( self:lengthSqr() )
end

function vector:lengthSqr()
	return self.x ^ 2 + self.y ^ 2
end

function vector:normalize()
	local length = self:length()
	return vector( self.x / length, self.y / length )
end

function vector:normalizeInPlace()
	local length = self:length()
	self.x = length == 0 and 0 or self.x / length
	self.y = length == 0 and 0 or self.y / length
end

function vector:toAngle()
	return math.atan2( self.y, self.x )
end

function vector.__add( a, b )
	return vector( a.x + b.x, a.y + b.y )
end

function vector.__sub( a, b )
	return vector( a.x - b.x, a.y - b.y )
end

function vector.__mul( a, b )
	if ( type( a ) == "number" ) then
		return vector( a * b.x, a * b.y )
	elseif ( type( b ) == "number" ) then
		return vector( b * a.x, b * a.y )
	else
		return vector( a.x * b.x, a.y * b.y )
	end
end

function vector.__eq( a, b )
	return a.x == b.x and a.y == b.y
end

function vector:__tostring()
	return "vector: (" .. self.x .. ", " .. self.y .. ")"
end

vector.origin = vector()
