--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: Shader class
--
--==========================================================================--

class( "shader" )

shader._shaders = shader._shaders or {}

function shader.getShader( name, width, height )
	return shader._shaders[ name ]( width, height )
end

function shader.register( class, name )
	shader._shaders[ name ] = class
	getfenv( 2 )[ name ] = nil
end

function shader:shader( width, height )
end

function shader:renderTo( func )
end

function shader:draw()
end

function shader:set( key, value )
end

function shader:__tostring()
	local t = getmetatable( self )
	setmetatable( self, {} )
	local s = string.gsub( tostring( self ), "table", "shader" )
	setmetatable( self, t )
	return s
end
