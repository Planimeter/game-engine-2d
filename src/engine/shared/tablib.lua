--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Extends the table library
--
--============================================================================--

require( "table" )

local ipairs       = ipairs
local pairs        = pairs
local setmetatable = setmetatable
local type         = type
local getmetatable = getmetatable
local typeof       = typeof
local print        = print
local tostring     = tostring
local math         = math

function table.append( a, b )
	for _, v in ipairs( b ) do
		a[ #a + 1 ] = v
	end
end

function table.clear( t )
	for k in pairs( t ) do
		t[ k ] = nil
	end
end

function table.copy( t, recursive )
	if ( t == nil ) then
		return nil
	end

	local copy = {}
	setmetatable( copy, getmetatable( t ) )
	for i, v in pairs( t ) do
		if ( type( v ) ~= "table" ) then
			copy[ i ] = v
		else
			recursive      = recursive or {}
			recursive[ t ] = copy
			if ( recursive[ v ] ) then
				copy[ i ] = recursive[ v ]
			else
				copy[ i ] = table.copy( v, recursive )
			end
		end
	end
	return copy
end

function table.shallowcopy( t )
	local copy = {}
	for k, v in pairs( t ) do
		copy[ k ] = v
	end
	return copy
end

function table.count( t, value )
	local count = 0
	for _, v in pairs( t ) do
		if ( typeof( v,     "table" ) and
			 typeof( value, "table" ) ) then
			if ( table.equal( v, value ) ) then
				count = count + 1
			end
		elseif ( v == value ) then
			count = count + 1
		end
	end
	return count
end

function table.equal( a, b )
	if ( getmetatable( a ) ~= getmetatable( b ) ) then
		return false
	end

	for k, v in pairs( a ) do
		if ( typeof( v,      "table" ) and
			 typeof( b[ k ], "table" ) and
			 not table.equal( v, b[ k ] ) ) then
			return false
		elseif ( v ~= b[ k ] ) then
			return false
		end
	end

	for k, v in pairs( b ) do
		if ( typeof( v,      "table" ) and
			 typeof( a[ k ], "table" ) and
			 not table.equal( v, a[ k ] ) ) then
			return false
		elseif ( v ~= a[ k ] ) then
			return false
		end
	end
	return true
end

function table.flatten( t )
	for k, v in pairs( t ) do
		if ( type( v ) == "table" ) then
			table.flatten( v )

			for l, w in pairs( v ) do
				t[ k .. "." .. l ] = w
			end
			t[ k ] = nil
		end
	end
end

function table.hasvalue( t, value )
	for k, v in pairs( t ) do
		if ( v == value ) then
			return k
		end
	end
	return nil
end

function table.len( t )
	local c = 0
	for _ in pairs( t ) do
		c = c + 1
	end
	return c
end

function table.merge( a, b )
	for k, v in pairs( b ) do
		a[ k ] = v
	end
end

function table.print( t, i )
	if ( t == nil ) then
		print( nil )
		return
	end

	i = i or 0

	local indent = ""
	for j = 1, i do
		indent = indent .. "\t"
	end

	for k, v in pairs( t ) do
		if ( k ~= "_G" and k ~= "_M" and type( v ) == "table" ) then
			print( indent .. k )
			table.print( v, i + 1 )
		else
			print( indent .. tostring( k ), v )
		end
	end
end

function table.raise( t )
	local sub, key
	for k, v in pairs( t ) do
		sub, key = string.match( k, "(.-)%.(.+)" )
		if ( sub and key ) then
			sub = tonumber( sub ) or sub
			t[ sub ]        = t[ sub ] or {}
			t[ sub ][ key ] = v
			t[ k ]          = nil
			table.raise( t[ sub ] )
			table.raise( t )
		end
	end
end

local random = math.random

function table.irandom( t )
	return t[ random( #t ) ]
end

function table.unique( t )
	local copy = {}
	for _, v in ipairs( t ) do
		if ( table.count( copy, v ) == 0 ) then
			copy[ #copy + 1 ] = v
		end
	end
	return copy
end
