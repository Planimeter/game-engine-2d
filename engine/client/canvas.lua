--=========== Copyright © 2018, Planimeter, All rights reserved. =============--
--
-- Purpose: Canvas class
--
--============================================================================--

class( "canvas" )

canvas._canvases = canvas._canvases or {}

local function copy( k )
	if ( string.find( k, "__" ) == 1 ) then
		return
	end

	canvas[ k ] = function( self, ... )
		local self = self._canvas
		return self[ k ]( self, ... )
	end
end

local _R = debug.getregistry()
for k in pairs( _R.Canvas ) do
	copy( k )
end

local function newCanvas( self, ... )
	self._canvas = love.graphics.newCanvas( ... )
end

function canvas.invalidateCanvases()
	for _, v in ipairs( canvas._canvases ) do
		if ( typeof( v, "fullscreencanvas" ) ) then
			newCanvas( v )
		end

		if ( v:shouldAutoRedraw() ) then
			v:invalidate()
		end
	end
end

local function noop()
end

function canvas:canvas( ... )
	local args       = { ... }
	self._drawFunc   = noop
	self.needsRedraw = false
	self.autoRedraw  = true
	table.insert( canvas._canvases, self )

	newCanvas( self, ... )

	setproxy( self )
end

local function render( self )
	local canvas = love.graphics.getCanvas()
	love.graphics.setCanvas( { self._canvas, stencil = true } )
	self:_drawFunc()
	love.graphics.setCanvas( canvas )
end

function canvas:draw( ... )
	if ( self.needsRedraw ) then
		local b = love.graphics.getBlendMode()
		love.graphics.setBlendMode( "alpha", "alphamultiply" )
		render( self )
		love.graphics.setBlendMode( b )
		self.needsRedraw = false
	end

	love.graphics.draw( self._canvas, ... )
end

function canvas:invalidate()
	self.needsRedraw = true
end

function canvas:renderTo( func )
	self._drawFunc = func
	render( self )
end

accessor( canvas, "autoRedraw", "should" )

function canvas:__tostring()
	local t = getmetatable( self )
	setmetatable( self, {} )
	local s = string.gsub( tostring( self ), "table", "canvas" )
	setmetatable( self, t )
	return s
end

function canvas:__gc()
	for i, v in ipairs( canvas._canvases ) do
		if ( v == self ) then
			table.remove( canvas._canvases, i )
		end
	end
end

class "fullscreencanvas" ( "canvas" )

function fullscreencanvas:fullscreencanvas()
	canvas.canvas( self )
end
