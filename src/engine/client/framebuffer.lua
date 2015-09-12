--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Framebuffer class
--
--============================================================================--

-- These values are preserved during real-time scripting.
local framebuffers = framebuffer and framebuffer.framebuffers or {}

local graphics = love.graphics

class( "framebuffer" )

framebuffer.framebuffers = framebuffers

function framebuffer.invalidateFramebuffers()
	for _, v in ipairs( framebuffer.framebuffers ) do
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
	table.insert( framebuffer.framebuffers, self )

	self:createFramebuffer( width, height )
end

function framebuffer:clear()
	if ( self._framebuffer ) then
		self._framebuffer:clear()
	end
end

function framebuffer:createFramebuffer( width, height )
	if ( not graphics.isSupported( "canvas" ) ) then
		return
	end

	if ( graphics.isSupported( "npot" ) ) then
		self._framebuffer = graphics.newCanvas( width, height )
	else
		local size = width > height and width  or
		             height > width and height or width
		size = math.nearestpow2( size )
		self._framebuffer = graphics.newCanvas( size, size )
	end
end

function framebuffer:draw()
	_G.graphics.setColor( color.white, true )
	graphics.setBlendMode( "premultiplied" )
		graphics.draw( self:getDrawable() )
	graphics.setBlendMode( "alpha" )
end

local _shim = nil

function framebuffer:getDrawable()
	if ( graphics.isSupported( "canvas" ) ) then
		if ( self.needsRedraw ) then
			graphics.setBlendMode( "alpha" )
			self:render()
			self.needsRedraw = false
		end
	else
		graphics.setBlendMode( "alpha" )
		self:render()
		self.needsRedraw = false

		if ( not _shim ) then
			_shim = _G.graphics.shim
		end

		return _shim:getDrawable()
	end

	return self._framebuffer
end

function framebuffer:getDesiredWidth()
	return self.requestedWidth
end

function framebuffer:getDesiredHeight()
	return self.requestedHeight
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

framebuffer.renderStack = {}

function framebuffer:render()
	if ( graphics.isSupported( "canvas" ) ) then
		graphics.setCanvas( self._framebuffer )
		table.insert( framebuffer.renderStack, self._framebuffer )
			self._drawFunc()
		table.remove( framebuffer.renderStack, #framebuffer.renderStack )
		graphics.setCanvas( framebuffer.renderStack[ #framebuffer.renderStack ] )
	else
		self._drawFunc()
	end
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

class "fullscreenframebuffer" ( "framebuffer" )

function fullscreenframebuffer:fullscreenframebuffer()
	framebuffer.framebuffer( self )
end

function fullscreenframebuffer:createFramebuffer()
	local width  = _G.graphics.getViewportWidth()
	local height = _G.graphics.getViewportHeight()
	framebuffer.createFramebuffer( self, width, height )
end
