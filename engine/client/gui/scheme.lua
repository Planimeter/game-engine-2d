--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Scheme class
--
--============================================================================--

module( "scheme", package.class )

schemes = schemes or {}

local properties = {}

function clear( name )
	properties[ name ] = {}
end

function getProperty( name, property )
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

function isLoaded( name )
	return schemes[ name ] ~= nil
end

function load( name )
	require( "schemes." .. name )
end

function _M:scheme( name )
	self.name = name
	schemes[ name ] = self
	clear( name )
end

function _M:__tostring()
	return "scheme: \"" .. self.name .. "\""
end
