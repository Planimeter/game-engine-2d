--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Gaussian blur fragment shader
--
--==========================================================================--

require( "shaders.shader" )

class "gaussianblur" ( "shader" )

local gaussianblur = shader._shaders[ "gaussianblur" ] or gaussianblur

function gaussianblur:gaussianblur()
	local width, height = love.graphics.getDimensions()
	self.scale = 1 / 2
	width  = width  * self.scale
	height = height * self.scale
	self.horizontalPass  = love.graphics.newCanvas( width, height, { dpiscale = 1 } )
	self.verticalPass    = love.graphics.newCanvas( width, height, { dpiscale = 1 } )
	-- local fragmentShader = love.filesystem.read( "shaders/gaussianblur.frag" )
	-- self.shader = love.graphics.newShader( fragmentShader )
end

function gaussianblur:renderTo( func )
	local shader = love.graphics.getShader()
	love.graphics.setShader( self.shader )

	local width, height = love.graphics.getDimensions()
	width  = width  * self.scale
	height = height * self.scale
	self.shader:send( "dir", { 1 / width, 0 } )
	self.horizontalPass:renderTo( function()
		love.graphics.push()
			love.graphics.scale( self.scale, self.scale )
			func()
		love.graphics.pop()
	end )

	local b = love.graphics.getBlendMode()
	love.graphics.setBlendMode( "alpha", "premultiplied" )

	self.shader:send( "dir", { 0, 1 / height } )
	self.verticalPass:renderTo( function()
		love.graphics.clear()
		love.graphics.draw( self.horizontalPass )
	end )

	love.graphics.setBlendMode( b )
	love.graphics.setShader( shader )
end

function gaussianblur:draw()
	love.graphics.setColor( color.white )
	love.graphics.draw( self.verticalPass, 0, 0, 0, 1 / self.scale )
end

function gaussianblur:set( key, value )
	if ( key == "sigma" ) then
		-- self.shader:send( "sigma", value )
		-- self.shader:send( "norm", 1/(math.sqrt(2*math.pi)*value) )
		-- self.shader:send( "support", (value * 3.0) )
		self:generateShader( value, (value * 3.0) )
	end

	return self
end

function gaussianblur:generateShader( sigma, support )
	-- See `shaders/gaussianblur.frag`
	-- Loop unroll Gaussian convolution
	local norm = 0
	local forLoop = {}
	local line = "acc += (Texel(tex, loc + %.1f * dir)) * %f;"
	for i = -support, support do
		local coeff = math.exp(-0.5 * i * i / (sigma * sigma));
		table.insert( forLoop, ( norm > 0 and "\t" or "" ) ..
			string.format( line, i, coeff )
		)
		norm = norm + coeff;
	end
	table.insert( forLoop, "\tacc *= 1/" .. norm .. ";\r\n" )

	local fragmentShader = [[
uniform vec2 dir;
vec4 effect( vec4 color, Image tex, vec2 texcoord, vec2 pixcoord )
{
	vec2 loc = texcoord;
	vec4 acc = vec4( 0.0 );
	]] .. table.concat( forLoop, "\r\n" ) .. [[
	return acc;
}
]]
	self.shader = love.graphics.newShader( fragmentShader )
end

shader.register( gaussianblur, "gaussianblur" )
