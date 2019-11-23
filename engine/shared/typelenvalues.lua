--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Type-length-values class
--
--==========================================================================--

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

function typelenvalues.bytesToFloat( bytes )
	bytes = reverse( bytes )

	local sign     = 1
	local mantissa = byte( bytes, 3 ) % 128
	for i = 2, 1, -1 do
		mantissa = mantissa * 256 + byte( bytes, i )
	end
	if ( byte( bytes, 4 ) > 127 ) then
		sign = -1
	end

	local exponent = ( byte( bytes, 4 ) % 128 ) * 2 +
	            floor( byte( bytes, 3 )         / 128 )
	if ( exponent == 0 ) then
		return 0
	end

	mantissa = sign * ( ldexp( mantissa, -23 ) + 1 )
	return ldexp( mantissa, exponent - 127 )
end

function typelenvalues.bytesToShort( bytes )
	bytes = reverse( bytes )

	local number = 0
	number = number + byte( bytes, 1 )
	number = number + byte( bytes, 2 ) * ( 2 ^ 8 )

	if ( number >= 2 ^ ( 2 * 8 - 1 ) ) then
		number = number - 2 ^ ( 2 * 8 )
	end

	return number
end

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

	local bytes = ""
	local byte  = 0
	number      = mantissa
	for i = 1, 6 do
		number, byte = getByte( number )
		bytes = bytes .. byte
	end

	number, byte = getByte( exponent * 16 + number )
	bytes = bytes .. byte

	number, byte = getByte( sign * 128 + number )
	bytes = bytes .. byte
	return reverse( bytes )
end

function typelenvalues.floatToBytes( number )
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
		mantissa = ( mantissa * 2 - 1 ) * ldexp( 0.5, 24 )
		exponent = exponent + 126
	end

	local bytes = ""
	local byte  = 0
	number, byte = getByte( mantissa )
	bytes = bytes .. byte

	number, byte = getByte( number )
	bytes = bytes .. byte

	number, byte = getByte( exponent * 128 + number )
	bytes = bytes .. byte

	number, byte = getByte( sign * 128 + number )
	bytes = bytes .. byte
	return reverse( bytes )
end

function typelenvalues.shortToBytes( number )
	number      = floor( number )

	local bytes = char( number % ( 2 ^ 8 ) )
	number      = floor( number / ( 2 ^ 8 ) )
	bytes       = bytes .. char( number % ( 2 ^ 8 ) )
	return reverse( bytes )
end

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

accessor( typelenvalues, "data" )
accessor( typelenvalues, "definitions" )
accessor( typelenvalues, "struct" )

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
	if ( struct == nil ) then
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
				insert( data, typelenvalues.shortToBytes( size ) )
			elseif ( key.type == "typelenvalues" ) then
				local size = len( value:serialize() )
				insert( data, typelenvalues.shortToBytes( size ) )
			end

			-- Insert data
			if ( key.type == "boolean" ) then
				insert( data, char( value and 1 or 0 ) )
			elseif ( key.type == "float" ) then
				insert( data, typelenvalues.floatToBytes( value ) )
			elseif ( key.type == "short" ) then
				insert( data, typelenvalues.shortToBytes( value ) )
			elseif ( key.type == "string" ) then
				insert( data, value )
			elseif ( key.type == "vector" ) then
				insert( data, typelenvalues.floatToBytes( value.x ) )
				insert( data, typelenvalues.floatToBytes( value.y ) )
			elseif ( key.type == "typelenvalues" ) then
				insert( data, value:serialize() )
			elseif ( key.type == "entity" ) then
				insert( data, typelenvalues.shortToBytes( value and value.entIndex or 0 ) )
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
	if ( self.struct == nil ) then
		local id = byte( data )
		for name, struct in pairs( self:getDefinitions() ) do
			if ( struct.id == id ) then
				self.struct = struct
			end
		end
		index = index + 1
	end

	if ( self.struct == nil ) then
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
			elseif ( key.type == "float" ) then
				size = 4
			elseif ( key.type == "short" ) then
				size = 2
			elseif ( key.type == "string" ) then
				size  = typelenvalues.bytesToShort( sub( data, index, index + 1 ) )
				index = index + 2
			elseif ( key.type == "vector" ) then
				size = 2 * 4
			elseif ( key.type == "typelenvalues" ) then
				size  = typelenvalues.bytesToShort( sub( data, index, index + 1 ) )
				index = index + 2
			elseif ( key.type == "entity" ) then
				size = 2
			end

			-- Get data
			bytes = sub( data, index, index + size - 1 )
			if ( key.type == "boolean" ) then
				self.data[ key.name ] = byte( bytes ) ~= 0
			elseif ( key.type == "float" ) then
				self.data[ key.name ] = typelenvalues.bytesToFloat( bytes )
			elseif ( key.type == "short" ) then
				self.data[ key.name ] = typelenvalues.bytesToShort( bytes )
			elseif ( key.type == "string" ) then
				self.data[ key.name ] = bytes
			elseif ( key.type == "vector" ) then
				self.data[ key.name ] = vector(
					typelenvalues.bytesToFloat( sub( bytes, 1, 4 ) ), --x
					typelenvalues.bytesToFloat( sub( bytes, 4, 8 ) )  --y
				)
			elseif ( key.type == "typelenvalues" ) then
				local tlvs = typelenvalues()
				tlvs.data  = bytes
				self.data[ key.name ] = tlvs
			elseif ( key.type == "entity" ) then
				local entIndex = typelenvalues.bytesToShort( bytes )
				entities.require( "entity" )
				self.data[ key.name ] = entity.getByEntIndex( entIndex )
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
