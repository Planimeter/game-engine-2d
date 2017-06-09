--=========== Copyright © 2017, Planimeter, All rights reserved. ===========--
--
-- Purpose: Image class
--
--==========================================================================--

class "gui.imagepanel" ( "gui.panel" )

function imagepanel:imagepanel( parent, name, image )
	gui.panel.panel( self, parent, name )
	self.color      = color( 255, 255, 255, 255 )
	self.imageDatum = nil
	self.imageQuad  = nil
	self:setImage( image )
end

local missingImage = false

function imagepanel:draw()
	gui.panel._maskedPanel = self
	love.graphics.stencil( gui.panel.drawMask )
	love.graphics.setStencilTest( "greater", 0 )
		love.graphics.setColor( self:getColor() )
		love.graphics.draw( self:getImage(), self:getQuad() )
	love.graphics.setStencilTest()

	missingImage = self:getImage() == nil
	if ( missingImage ) then
		self:drawMissingImage()
	end
end

function imagepanel:drawMissingImage()
	love.graphics.setColor( color( color.red, 255 * 0.42 ) )
	local lineWidth = 1
	local width     = self:getWidth()
	local height    = self:getHeight()
	love.graphics.setLineWidth( lineWidth )
	love.graphics.line(
		width - lineWidth / 2, 0,                      -- Top-right
		width - lineWidth / 2, height - lineWidth / 2, -- Bottom-right
		0,                     height - lineWidth / 2  -- Bottom-left
	)
end

accessor( imagepanel, "color" )

function imagepanel:getQuad()
	return self.imageQuad
end

function imagepanel:getImage()
	return self.imageDatum
end

function imagepanel:setImage( image )
	if ( type( image ) == "image" ) then
		self.imageDatum = image
	elseif ( image ~= nil and love.filesystem.exists( image ) ) then
		self.imageDatum = love.graphics.newImage( image )
		self.imageDatum:setFilter( "linear", "linear" )
	else
		self.imageDatum = nil
	end

	self:updateQuad()
end

function imagepanel:setWidth( width )
	gui.panel.setWidth( self, width )
	self:updateQuad()
end

function imagepanel:setHeight( height )
	gui.panel.setHeight( self, height )
	self:updateQuad()
end

local w, h, sw, sh = 0, 0, 0, 0

function imagepanel:updateQuad()
	missingImage = self:getImage() == nil
	w  = self:getWidth()  - ( missingImage and love.window.toPixels( 1 ) or 0 )
	h  = self:getHeight() - ( missingImage and love.window.toPixels( 1 ) or 0 )
	sw = self.imageDatum:getWidth()
	sh = self.imageDatum:getHeight()
	if ( self.imageQuad == nil ) then
		self.imageQuad = love.graphics.newQuad( 0, 0, w, h, sw, sh )
	else
		self.imageQuad:setViewport( 0, 0, w, h )
	end
end
