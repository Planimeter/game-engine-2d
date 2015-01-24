--========= Copyright © 2013-2014, Planimeter, All rights reserved. ==========--
--
-- Purpose: Throbber class
--
--============================================================================--

class "throbber" ( gui.image )

function throbber:throbber( parent, name, image )
	gui.image.image( self, parent, name, image or "images/gui/throbber.png" )
	self:setSize( 16, 16 )
	self:setOpacity( 0 )
end

local missingImage = false

function throbber:draw()
	if ( not self:isVisible() ) then
		return
	end

	gui.image.maskedImage = self
	graphics.setStencil( gui.image.drawMask )
		graphics.setColor( self:getColor() )
		graphics.draw( self:getImage(),
					   self:getWidth()	/ 2,
					   self:getHeight()	/ 2,
					   engine.getRealTime() % 2 * math.pi,
					   1,
					   1,
					   self:getWidth()	/ 2,
					   self:getHeight() / 2 )
	graphics.setStencil()

	missingImage = self:getImage() == graphics.error
	if ( missingImage ) then
		self:drawMissingImage()
	end

	gui.panel.draw( self )
end

function throbber:enable()
	self.enabled = true
end

function throbber:disable()
	self.enabled = false
end

function throbber:isEnabled()
	return self.enabled
end

function throbber:update( dt )
	if ( self:isVisible() and self:getOpacity() ~= 0 ) then
		self:invalidate()
	end

	-- FIXME: self:animate doesn't work for gui.throbber
	if ( self.enabled and self:getOpacity() ~= 1 ) then
		self:setOpacity( math.min( self:getOpacity() + dt * ( 1 / 0.4 ), 1 ) )
	elseif ( self:getOpacity() ~= 0 ) then
		self:setOpacity( math.max( self:getOpacity() - dt * ( 1 / 0.4 ), 0 ) )
	end
end

gui.register( throbber, "throbber" )
