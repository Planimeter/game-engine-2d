--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
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
		graphics.setCanvas( self._framebuffer )
			graphics.clear()
		graphics.setCanvas()
	end
end

function framebuffer:createFramebuffer( width, height )
	self._framebuffer = graphics.newCanvas( width, height )
end

function framebuffer:draw()
	_G.graphics.setColor( color.white, true )
	graphics.setBlendMode( "alpha", "premultiplied" )
		graphics.draw( self:getDrawable() )
	graphics.setBlendMode( "alpha", "alphamultiply" )
end

function framebuffer:getDrawable()
	if ( self.needsRedraw ) then
		graphics.setBlendMode( "alpha" )
		self:render()
		self.needsRedraw = false
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
	graphics.setCanvas( self._framebuffer )
	table.insert( framebuffer.renderStack, self._framebuffer )
		self._drawFunc()
	table.remove( framebuffer.renderStack, #framebuffer.renderStack )
	graphics.setCanvas( framebuffer.renderStack[ #framebuffer.renderStack ] )
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
