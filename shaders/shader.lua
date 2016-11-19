--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Shader class
--
--============================================================================--

local getfenv      = getfenv
local getmetatable = getmetatable
local setmetatable = setmetatable
local tostring     = tostring

module( "shader", package.class )

shaders = shaders or {}

function getShader( name )
	return shaders[ name ]()
end

function register( class, name )
	shaders[ name ] = class
	getfenv( 2 )[ name ] = nil
end

function _M:renderTo( func )
end

function _M:draw()
end

function _M:set( key, value )
end

function _M:__tostring()
	local t = getmetatable( self )
	setmetatable( self, {} )
	local s = string.gsub( tostring( self ), "table", "shader" )
	setmetatable( self, t )
	return s
end
