--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Image class
--
--============================================================================--

class "image" ( gui.panel )

image.maskedImage = image.maskedImage or nil

function image.drawMask()
	local self = gui.image.maskedImage
	graphics.rectangle( "fill",
						0,
						0,
						self:getWidth(),
						self:getHeight() )
end

function image:image( parent, name, image )
	gui.panel.panel( self, parent, name )
	self.color		= color( 255, 255, 255, 255 )
	self.imageDatum = nil
	self.imageQuad	= nil
	self:setImage( image )
end

local missingImage = false

function image:draw()
	if ( not self:isVisible() ) then
		return
	end

	gui.image.maskedImage = self
	graphics.setStencil( gui.image.drawMask )
		graphics.setColor( self:getColor() )
		graphics.draw( self:getImage(), self:getQuad() )
	graphics.setStencil()

	missingImage = self:getImage() == graphics.error
	if ( missingImage ) then
		self:drawMissingImage()
	end
end

local opacity = 1

function image:drawMissingImage()
	opacity = graphics.getOpacity()
	graphics.setOpacity( 0.42 )
		graphics.setColor( color.red )
		local width	 = self:getWidth()
		local height = self:getHeight()
		graphics.line( width - 1, -0.5,
					   width - 1, height - 1,
					   0,		  height - 1 )
	graphics.setOpacity( opacity )
end

function image:getColor()
	return self.color
end

function image:getQuad()
	return self.imageQuad
end

function image:getImage()
	return self.imageDatum
end

function image:setColor( color )
	self.color = color
end

function image:setImage( image )
	if ( type( image ) == "Image" ) then
		self.imageDatum = image
	elseif ( image ~= nil and filesystem.exists( image ) ) then
		self.imageDatum = graphics.newImage( image )
	else
		self.imageDatum = graphics.error
	end

	self:updateQuad()
end

function image:setWidth( width )
	gui.panel.setWidth( self, width )
	self:updateQuad()
end

function image:setHeight( height )
	gui.panel.setHeight( self, height )
	self:updateQuad()
end

local w, h, sw, sh = 0, 0, 0, 0

function image:updateQuad()
	missingImage = self:getImage() == graphics.error
	w  = self:getWidth()  - ( missingImage and 1 or 0 )
	h  = self:getHeight() - ( missingImage and 1 or 0 )
	sw = self.imageDatum:getWidth()
	sh = self.imageDatum:getHeight()
	if ( self.imageQuad == nil ) then
		self.imageQuad = graphics.newQuad( 0, 0, w, h, sw, sh )
	else
		self.imageQuad:setViewport( 0, 0, w, h )
	end
end

gui.register( image, "image" )
