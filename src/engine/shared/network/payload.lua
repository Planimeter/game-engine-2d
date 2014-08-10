--========= Copyright © 2013-2014, Planimeter, All rights reserved. ==========--
--
-- Purpose: Payload class
--
--============================================================================--

-- These values are preserved during real-time scripting.
local _handlers = payload and payload.handlers or {}

class( "payload" )

payload.handlers = _handlers
local handlers	 = payload.handlers

unrequire( "engine.shared.network.payloads" )
require( "engine.shared.network.payloads" )

-- Generate ids for packet structures
local pairs   = pairs
local structs = payload.structs
local id	  = 1
for k, v in pairs( payload.structs ) do
	structs[ k ].id	= id
	id				= id + 1
end

function payload.initializeFromData( data )
	local payload = payload()
	payload.data  = data
	payload:deserialize()
	return payload
end

local reverse = string.reverse
local byte	  = string.byte
local floor	  = math.floor
local ldexp	  = math.ldexp

function payload.bytesToNumber( bytes )
	bytes = reverse( bytes )

	local sign	   = 1
	local mantissa = byte( bytes, 7 ) % 16
	for i = 6, 1, -1 do
		mantissa = mantissa * 256 + byte( bytes, i )
	end

	if ( byte( bytes, 8 ) > 127 ) then
		sign = -1
	end

	local exponent =	  ( byte( bytes, 8 ) % 128 ) * 16 +
					 floor( byte( bytes, 7 )		 / 16 )
	if ( exponent == 0 ) then
		return 0
	end

	mantissa = sign * ( ldexp( mantissa, -52 ) + 1 )
	return ldexp( mantissa, exponent - 1023 )
end

local bytesToNumber = payload.bytesToNumber

local char = string.char

local function getByte( v )
	return floor( v / 256 ), char( floor( v ) % 256 )
end

local frexp = math.frexp

function payload.numberToBytes( number )
	local sign = 0

	if ( number < 0 ) then
		sign   = 1
		number = -number
	end

	local mantissa, exponent = frexp( number )
	if ( number == 0 ) then
		mantissa = 0
		exponent = 0
	else
		mantissa = ( mantissa * 2 - 1 ) * ldexp( 0.5, 53 )
		exponent = exponent + 1022
	end

	local v	   = ""
	local byte = 0
	number	   = mantissa
	for i = 1, 6 do
		number, byte = getByte( number )
		v			 = v .. byte
	end

	number, byte = getByte( exponent * 16 + number )
	v			 = v .. byte

	number, byte = getByte( sign * 128 + number )
	v			 = v .. byte
	return reverse( v )
end

local numberToBytes = payload.numberToBytes

function payload.setHandler( func, struct )
	handlers[ struct ] = func
end

function payload:payload( struct )
	self.struct = structs[ struct ]
	self.data	= {}
end

function payload:dispatchToHandler()
	local name = self:getStructName()
	if ( name ) then
		local handler = handlers[ name ]
		if ( handler ) then
			handler( self )
		end
	end
end

function payload:get( key )
	return self.data[ key ]
end

function payload:getData()
	return self.data
end

function payload:getPeer()
	return self.peer
end

function payload:getStructName()
	for name, struct in pairs( structs ) do
		if ( struct == self.struct ) then
			return name
		end
	end
end

local insert = table.insert
local len	 = string.len
local concat = table.concat

function payload:serialize()
	local struct = self.struct
	local id	 = struct.id
	local keys	 = struct.keys

	local data = {}

	-- Insert struct id
	insert( data, char( id ) )

	for i, key in ipairs( keys ) do
		local value = self.data[ key.name ]
		if ( value ~= nil ) then
			-- Insert key id
			insert( data, char( i ) )

			-- Insert length
			if ( key.type == "boolean" ) then
				-- UNDONE: We'll always know this length!!
				-- insert( data, numberToBytes( 1 ) )
			elseif ( key.type == "number" ) then
				-- UNDONE: We'll always know this length!!
				-- insert( data, numberToBytes( 8 ) )
			elseif ( key.type == "string" ) then
				local size = len( value )
				insert( data, numberToBytes( size ) )
			end

			-- Insert data
			if ( key.type == "boolean" ) then
				insert( data, char( value and 1 or 0 ) )
			elseif ( key.type == "number" ) then
				insert( data, numberToBytes( value ) )
			elseif ( key.type == "string" ) then
				insert( data, value )
			elseif ( key.type == "vector" ) then
				insert( data, numberToBytes( value.x ) )
				insert( data, numberToBytes( value.y ) )
			else
				print( "Can't serialize " .. key.type .. " for " ..
					   self:getStructName() .. " payload!" )
			end
		end
	end

	return concat( data )
end

local ipairs = ipairs
local sub	 = string.sub

function payload:deserialize()
	local data = self.data
	self.data  = {}

	-- Get struct by id
	local id	= byte( data )
	local index = 1
	for name, struct in pairs( structs ) do
		if ( struct.id == id ) then
			self.struct = struct
		end
	end
	index = index + 1

	if ( not self.struct ) then
		return
	end

	local keys	= self.struct.keys
	local id	= -1
	local key	= nil
	local size	= -1
	local bytes = nil
	while ( index < len( data ) ) do
		-- Get key id
		id	  = byte( data, index )
		index = index + 1
		key	  = nil
		for i, v in ipairs( keys ) do
			if ( id == i ) then
				key = v
			end
		end

		-- Get length
		size = -1
		if ( key ) then
			if ( key.type == "boolean" ) then
				size = 1
			elseif ( key.type == "number" ) then
				size = 8
			elseif ( key.type == "string" ) then
				size  = bytesToNumber( sub( data, index, index + 7 ) )
				index = index + 8
			elseif ( key.type == "vector" ) then
				size = 2 * 8
			end

			-- Get data
			bytes = sub( data, index, index + size - 1 )
			if ( key.type == "boolean" ) then
				self.data[ key.name ] = byte( bytes ) ~= 0
			elseif ( key.type == "number" ) then
				self.data[ key.name ] = bytesToNumber( bytes )
			elseif ( key.type == "string" ) then
				self.data[ key.name ] = bytes
			elseif ( key.type == "vector" ) then
				require( "common.vector" )
				self.data[ key.name ] = vector(
					bytesToNumber( sub( bytes, 1, 8 ) ), --x
					bytesToNumber( sub( bytes, 8, 16 ) ) --y
				)
			end
			index = index + size
		else
			return
		end
	end
end

function payload:set( key, value )
	self.data[ key ] = value
end

function payload:setPeer( peer )
	self.peer = peer
end

function payload:__tostring()
	return self:serialize()
end
