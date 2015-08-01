--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Type-length-values class
--
--============================================================================--

class( "typelenvalues" )

local reverse = string.reverse
local byte    = string.byte
local floor   = math.floor
local ldexp   = math.ldexp

function typelenvalues.bytesToNumber( bytes )
	bytes = reverse( bytes )

	local sign     = 1
	local mantissa = byte( bytes, 7 ) % 16
	for i = 6, 1, -1 do
		mantissa = mantissa * 256 + byte( bytes, i )
	end

	if ( byte( bytes, 8 ) > 127 ) then
		sign = -1
	end

	local exponent = ( byte( bytes, 8 ) % 128 ) * 16 +
	            floor( byte( bytes, 7 )         / 16 )
	if ( exponent == 0 ) then
		return 0
	end

	mantissa = sign * ( ldexp( mantissa, -52 ) + 1 )
	return ldexp( mantissa, exponent - 1023 )
end

local bytesToNumber = typelenvalues.bytesToNumber

local char = string.char

local function getByte( v )
	return floor( v / 256 ), char( floor( v ) % 256 )
end

local frexp = math.frexp

function typelenvalues.numberToBytes( number )
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

	local v    = ""
	local byte = 0
	number     = mantissa
	for i = 1, 6 do
		number, byte = getByte( number )
		v = v .. byte
	end

	number, byte = getByte( exponent * 16 + number )
	v = v .. byte

	number, byte = getByte( sign * 128 + number )
	v = v .. byte
	return reverse( v )
end

local numberToBytes = typelenvalues.numberToBytes

local pairs = pairs

function typelenvalues.generateIds( definitions )
	local id = 1
	for _, v in pairs( definitions ) do
		v.id = id
		id   = id + 1
	end
end

function typelenvalues:typelenvalues( definitions, struct )
	self.data = {}

	self:setDefinitions( definitions )

	if ( type( struct ) == "string" ) then
		struct = self:getStructDefinition( struct )
	end
	self:setStruct( struct )
end

function typelenvalues:get( key )
	return self.data[ key ]
end

function typelenvalues:getData()
	return self.data
end

function typelenvalues:getDefinitions()
	return self.definitions
end

function typelenvalues:getStruct()
	return self.struct
end

function typelenvalues:getStructDefinition( struct )
	local definitions = self:getDefinitions()
	return definitions[ struct ]
end

function typelenvalues:getStructName()
	for name, struct in pairs( self.definitions ) do
		if ( struct == self.struct ) then
			return name
		end
	end
end

local insert = table.insert
local len    = string.len
local concat = table.concat

function typelenvalues:serialize()
	local struct = self:getStruct()
	if ( not struct ) then
		return ""
	end

	local id   = struct.id
	local keys = struct.keys

	local data = {}

	-- Insert struct id
	if ( id ) then
		insert( data, char( id ) )
	end

	for i, key in ipairs( keys ) do
		local value = self:get( key.name )
		if ( value ~= nil ) then
			-- Insert key id
			insert( data, char( i ) )

			-- Insert length if necessary
			if ( key.type == "string" ) then
				local size = len( value )
				insert( data, numberToBytes( size ) )
			elseif ( key.type == "typelenvalues" ) then
				local size = len( value:serialize() )
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
			elseif ( key.type == "typelenvalues" ) then
				insert( data, value:serialize() )
			else
				print( "Can't serialize " .. key.type .. " for " ..
				       self:getStructName() .. "!" )
			end
		end
	end

	return concat( data )
end

local ipairs = ipairs
local sub    = string.sub

function typelenvalues:deserialize()
	local data = self:getData()
	self.data  = {}

	-- Get struct by id
	local index = 1
	if ( not self.struct ) then
		local id = byte( data )
		for name, struct in pairs( self:getDefinitions() ) do
			if ( struct.id == id ) then
				self.struct = struct
			end
		end
		index = index + 1
	end

	if ( not self.struct ) then
		return
	end

	local keys  = self.struct.keys
	local id    = -1
	local key   = nil
	local size  = -1
	local bytes = nil
	while ( index < len( data ) ) do
		-- Get key id
		id    = byte( data, index )
		index = index + 1
		key   = nil
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
			elseif ( key.type == "typelenvalues" ) then
				size  = bytesToNumber( sub( data, index, index + 7 ) )
				index = index + 8
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
			elseif ( key.type == "typelenvalues" ) then
				local tlvs = typelenvalues()
				tlvs.data  = bytes
				self.data[ key.name ] = tlvs
			end
			index = index + size
		else
			return
		end
	end
end

function typelenvalues:set( key, value )
	self.data[ key ] = value
end

function typelenvalues:setDefinitions( definitions )
	self.definitions = definitions
end

function typelenvalues:setStruct( struct )
	self.struct = struct
end

function typelenvalues:__tostring()
	if ( self:getStruct() ) then
		return self:serialize()
	else
		local t = getmetatable( self )
		setmetatable( self, {} )
		local s = string.gsub( tostring( self ), "table", "typelenvalues" )
		setmetatable( self, t )
		return s
	end
end
