--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Framebuffer class
--
--============================================================================--

-- These values are preserved during real-time scripting.
local _framebuffers = framebuffer and framebuffer._framebuffers or {}
local _renderStack  = framebuffer and framebuffer._renderStack  or {}

module( "framebuffer", package.class )

framebuffer._framebuffers = _framebuffers

function framebuffer.invalidateFramebuffers()
	for _, v in ipairs( _framebuffers ) do
		if ( typeof( v, "fullscreenframebuffer" ) ) then
			v:createFramebuffer()
		end

		if ( v:shouldAutoRedraw() ) then
			v:invalidate()
		end
	end
end

function framebuffer:framebuffer( width, height )
	self.desiredWidth  = width
	self.desiredHeight = height
	self._drawFunc     = nil
	self.needsRedraw   = false
	self.autoRedraw    = true
	table.insert( _framebuffers, self )

	self:createFramebuffer( width, height )
end

function framebuffer:clear()
	if ( self._framebuffer ) then
		love.graphics.setCanvas( self._framebuffer )
			love.graphics.clear()
		love.graphics.setCanvas()
	end
end

function framebuffer:createFramebuffer( width, height )
	self._framebuffer = love.graphics.newCanvas( width, height )
end

function framebuffer:draw()
	_G.graphics.setColor( color.white, true )
	love.graphics.setBlendMode( "alpha", "premultiplied" )
		love.graphics.draw( self:getDrawable() )
	love.graphics.setBlendMode( "alpha", "alphamultiply" )
end

function framebuffer:getDrawable()
	if ( self.needsRedraw ) then
		love.graphics.setBlendMode( "alpha" )
		self:render()
		self.needsRedraw = false
	end

	return self._framebuffer
end

function framebuffer:getWidth()
	return self._framebuffer:getWidth()
end

function framebuffer:getHeight()
	return self._framebuffer:getHeight()
end

function framebuffer:invalidate()
	self.needsRedraw = true
end

framebuffer._renderStack = _renderStack

function framebuffer:render()
	love.graphics.setCanvas( self._framebuffer )
	table.insert( _renderStack, self._framebuffer )
		self._drawFunc()
	table.remove( _renderStack, #_renderStack )
	love.graphics.setCanvas( _renderStack[ #_renderStack ] )
end

function framebuffer:renderTo( func )
	self._drawFunc = func
	self:render()
end

function framebuffer:setAutoRedraw( autoRedraw )
	self.autoRedraw = autoRedraw
end

function framebuffer:shouldAutoRedraw()
	return self.autoRedraw
end

function framebuffer:__tostring()
	local t = getmetatable( self )
	setmetatable( self, {} )
	local s = string.gsub( tostring( self ), "table", "framebuffer" )
	setmetatable( self, t )
	return s
end

module( "fullscreenframebuffer", package.class, package.inherit( "framebuffer" ) )

function fullscreenframebuffer:fullscreenframebuffer()
	framebuffer.framebuffer( self )
end

function fullscreenframebuffer:createFramebuffer()
	local width  = love.graphics.getWidth()
	local height = love.graphics.getHeight()
	framebuffer.createFramebuffer( self, width, height )
end
