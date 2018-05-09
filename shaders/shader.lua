--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: Shader class
--
--==========================================================================--

class( "shader" )

shader.shaders = shader.shaders or {}

function shader.getShader( name )
	return shader.shaders[ name ]()
end

function shader.register( class, name )
	shader.shaders[ name ] = class
	getfenv( 2 )[ name ] = nil
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
