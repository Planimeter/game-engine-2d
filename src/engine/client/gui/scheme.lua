--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Scheme class
--
--============================================================================--

-- These values are preserved during real-time scripting.
local schemes = scheme and scheme.schemes or {}

class( "scheme" )

scheme.schemes = schemes

local properties = {}

function scheme.clear( name )
	properties[ name ] = {}
end

function scheme.getProperty( name, property )
	local cachedProperty = properties[ name ][ property ]
	if ( cachedProperty ) then
		return cachedProperty
	end

	local value = scheme.schemes[ name ]
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
