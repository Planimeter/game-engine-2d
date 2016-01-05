--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Extends the math library
--
--============================================================================--

require( "math" )

function math.clamp( n, l, u )
	return n < l and ( l ) or
	                 ( n > u and ( u ) or
	                             ( n ) )
end

function math.gcd( a, b )
	local t = 0
	while b ~= 0 do
		t = b
		b = a % b
		a = t
	end
	return a
end

function math.remap( n, inMin, inMax, outMin, outMax )
	return ( n / ( inMax - inMin ) ) * ( outMax - outMin ) + outMin
end

function math.lerp( f, t, dt )
	return ( f + ( t - f ) * dt )
end

local floor = math.floor

function math.round( n )
	return floor( n + 0.5 )
end

local pow  = math.pow
local ceil = math.ceil
local log  = math.log

function math.nearestpow2( n )
	return pow( 2, ceil( log( n ) / log( 2 ) ) )
end

math.phi = ( 1 + math.sqrt( 5 ) ) / 2

function math.pointinrectangle( px, py, x, y, width, height )
	return px >= x and
	       py >= y and
	       px < x + width and
	       py < y + height
end

function math.aabbsintersect( minA, maxA, minB, maxB )
	return minA.x <= maxB.x and
	       maxA.x >= minB.x and
	       maxA.y <= minB.y and
	       minA.y >= maxB.y
end
