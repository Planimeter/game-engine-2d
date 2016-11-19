--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Vector class
--
--============================================================================--

local math = math
local type = type

module( "vector", package.class )

function copy( v )
	return _M( v.x, v.y )
end

function _M:vector( x, y )
	self.x = x or 0
	self.y = y or 0
end

function _M:length()
	return math.sqrt( self:lengthSqr() )
end

function _M:lengthSqr()
	return self.x ^ 2 + self.y ^ 2
end

function _M:normalize()
	local length = self:length()
	return _M( self.x / length, self.y / length )
end

function _M:normalizeInPlace()
	local length = self:length()
	self.x = length == 0 and 0 or self.x / length
	self.y = length == 0 and 0 or self.y / length
end

function _M:toAngle()
	return math.atan2( self.y, self.x )
end

function __add( a, b )
	return _M( a.x + b.x, a.y + b.y )
end

function __sub( a, b )
	return _M( a.x - b.x, a.y - b.y )
end

function __mul( a, b )
	if ( type( a ) == "number" ) then
		return _M( a * b.x, a * b.y )
	elseif ( type( b ) == "number" ) then
		return _M( b * a.x, b * a.y )
	else
		return _M( a.x * b.x, a.y * b.y )
	end
end

function __eq( a, b )
	return a.x == b.x and a.y == b.y
end

function _M:__tostring()
	return "vector: (" .. self.x .. ", " .. self.y .. ")"
end

origin = _M()
