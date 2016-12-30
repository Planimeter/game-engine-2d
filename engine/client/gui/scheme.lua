--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Scheme class
--
--============================================================================--

class( "scheme" )

scheme.schemes = scheme.schemes or {}

local properties = {}

function scheme.clear( name )
	properties[ name ] = {}
end

function scheme.getProperty( name, property )
	local cachedProperty = properties[ name ][ property ]
	if ( cachedProperty ) then
		return cachedProperty
	end

	local value = schemes[ name ]
	local type  = type( value )
	if ( type ~= "scheme" ) then
		error( "attempt to index scheme '" .. name .. "' " ..
		       "(a " .. type .. " value)", 3 )
	end

	for key in string.gmatch( property .. ".", "(.-)%." ) do
		if ( value and value[ key ] ) then
			value = value[ key ]
			properties[ name ][ property ] = value
		else
			error( "attempt to index property '" .. property .. "' " ..
			       "(a nil value)", 3 )
		end
	end

	return value
end

function scheme.isLoaded( name )
	return scheme.schemes[ name ] ~= nil
end

function scheme.load( name )
	require( "schemes." .. name )
end

function scheme:scheme( name )
	self.name = name
	scheme.schemes[ name ] = self
	scheme.clear( name )
end

function scheme:__tostring()
	return "scheme: \"" .. self.name .. "\""
end
