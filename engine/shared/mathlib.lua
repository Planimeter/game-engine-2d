--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Extends the math library
--
--==========================================================================--

require( "math" )

function math.aabbsintersect( minA, maxA, minB, maxB )
	return minA.x <= maxB.x and
	       maxA.x >= minB.x and
	       maxA.y <= minB.y and
	       minA.y >= maxB.y
end

math.fepsilon = 1e-5

function math.approximately( a, b )
	-- Calculate the difference.
	local diff = math.abs( a - b )
	a = math.abs( a )
	b = math.abs( b )
	-- Find the largest
	local largest = ( b > a ) and b or a

	if ( diff <= largest * math.fepsilon ) then
		return true
	end

	return false
end

function math.clamp( n, l, u )
	return n < l and l or ( n > u and u or n )
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

function math.lerp( f, t, dt )
	return ( f + ( t - f ) * dt )
end

function math.nearestmult( n, mult )
	return math.round( n / mult ) * mult
end

function math.nearestpow2( n )
	return 2 ^ math.ceil( math.log( n ) / math.log( 2 ) )
end

math.phi = ( 1 + math.sqrt( 5 ) ) / 2

function math.pointinrect( px, py, x, y, width, height )
	return px >= x and
	       py >= y and
	       px < x + width and
	       py < y + height
end

function math.pointonline( x1, y1, x2, y2, px, py )
	local m = ( y2 - y1 ) / ( x2 - x1 )
	local b = y1 - m * x1
	return py == m * px + b
end

function math.pointonlinesegment( x1, y1, x2, y2, px, py )
	-- Test x out of bounds
	if ( x2 > x1 and px > x2 ) then
		return false
	elseif ( x2 < x1 and px < x2 ) then
		return false
	end

	-- Test y out of bounds
	if ( y2 > y1 and py > y2 ) then
		return false
	elseif ( y2 < y1 and py < y2 ) then
		return false
	end

	return math.pointonline( x1, y1, x2, y2, px, py )
end

function math.remap(v, srcLow, srcHigh, destLow, destHigh)
    return destLow + (destHigh - destLow) * (v - srcLow) / (srcHigh - srcLow)
end

function math.remapClamp(v, srcLow, srcHigh, destLow, destHigh)
    return destLow + (destHigh - destLow) * math.clamp((v - srcLow) / (srcHigh - srcLow), 0, 1)
end

function math.round( n )
	return math.floor( n + 0.5 )
end
