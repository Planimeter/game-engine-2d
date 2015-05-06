--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Gaussian Blur shader
--
--============================================================================--

--[[
The MIT License (MIT)

Copyright (c) 2015 Matthias Richter

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]--

require( "shaders.shader" )

class "gaussianblur" ( "shader" )

-- unroll convolution loop
local function build_shader(sigma)
	local support = math.max(1, math.floor(3*sigma + .5))
	local one_by_sigma_sq = sigma > 0 and 1 / (sigma * sigma) or 1
	local norm = 0

	local code = {[[
		extern vec2 direction;
		vec4 effect(vec4 color, Image texture, vec2 tc, vec2 _)
		{ vec4 c = vec4(0.0f);
	]]}
	local blur_line = "c += vec4(%f) * Texel(texture, tc + vec2(%f) * direction);"

	for i = -support,support do
		local coeff = math.exp(-.5 * i*i * one_by_sigma_sq)
		norm = norm + coeff
		code[#code+1] = blur_line:format(coeff, i)
	end

	code[#code+1] = ("return c * vec4(%f) * color;}"):format(norm > 0 and 1/norm or 1)

	return graphics.newShader(table.concat(code))
end

function gaussianblur:gaussianblur()
	self.canvas_h = graphics.newFullscreenFramebuffer()
	self.canvas_v = graphics.newFullscreenFramebuffer()
	self.shader = build_shader(1)
	self.shader:send("direction",{1.0,0.0})
end

function gaussianblur:draw(func)
	local s = graphics.getShader()

	-- draw scene
	self.canvas_h:clear()
	self.canvas_h:renderTo(func)

	graphics.setShader(self.shader)

	local b = graphics.getBlendMode()
	graphics.setBlendMode('premultiplied')

	-- first pass (horizontal blur)
	self.shader:send('direction', {1 / graphics.getViewportWidth(), 0})
	self.canvas_v:clear()
	self.canvas_v:renderTo(function() graphics.draw(self.canvas_h:getDrawable(), 0,0) end)

	-- second pass (vertical blur)
	self.shader:send('direction', {0, 1 / graphics.getViewportHeight()})
	graphics.draw(self.canvas_v:getDrawable(), 0,0)

	-- restore blendmode, shader and canvas
	graphics.setBlendMode(b)
	graphics.setShader(s)
end

function gaussianblur:set(key, value)
	if key == "sigma" then
		self.shader = build_shader(tonumber(value))
	else
		error("Unknown property: " .. tostring(key))
	end
	return self
end

shader.register( gaussianblur, "gaussianblur" )
