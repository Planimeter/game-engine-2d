--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Extends the table library
--
--==========================================================================--

require( "table" )

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
	if ( type( t ) ~= "table" ) then
		typerror( 1, "table", t )
	end

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

function table.keys( t )
	local keys = {}
	for k in pairs( t ) do
		table.insert( keys, k )
	end
	return keys
end

function table.len( t )
	if ( type( t ) ~= "table" ) then
		typerror( 1, "table", t )
	end

	local c = 0
	for _ in pairs( t ) do
		c = c + 1
	end
	return c
end

function table.map( t, callback )
	local copy = {}
	for k, v in pairs( t ) do
		copy[ k ] = callback( k, v )
	end
	return copy
end

function table.merge( a, b )
	for k, v in pairs( b ) do
		a[ k ] = v
	end
end

function table.prepend( a, b )
	for i = #b, 1, -1 do
		table.insert( a, 1, b[ i ] )
	end
end

function table.print( t, i, printed )
	if ( t == nil ) then
		print( nil )
		return
	end

	printed = printed or {}
	printed[ t ] = true

	i = i or 0
	local indent = string.rep( "\t", i )
	for k, v in pairs( t ) do
		if ( type( v ) == "table" and not printed[ v ] ) then
			print( indent .. tostring( k ) )
			table.print( v, i + 1, printed )
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

function table.irandom( t )
	return t[ math.random( #t ) ]
end

function table.tostring( t )
	for i, v in ipairs( t ) do
		t[ i ] = tostring( v )
	end
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
