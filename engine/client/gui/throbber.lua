--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Throbber class
--
--============================================================================--

class "gui.throbber" ( "gui.imagepanel" )

function throbber:throbber( parent, name, image )
	gui.imagepanel.imagepanel( self, parent, name, image or "images/gui/throbber.png" )
	self:setSize( point( 16 ), point( 16 ) )
	self:setOpacity( 0 )
end

local missingImage = false

function throbber:draw()
	gui.imagepanel.maskedImage = self
	love.graphics.stencil( gui.imagepanel.drawMask )
	love.graphics.setStencilTest( "greater", 0 )
		love.graphics.setColor( self:getColor() )
		local image  = self:getImage()
		local width  = self:getWidth()
		local height = self:getHeight()
		love.graphics.draw(
			image,
			width  / 2,
			height / 2,
			love.timer.getTime() % 2 * math.pi,
			1,
			1,
			width  / 2,
			height / 2
		)
	love.graphics.setStencilTest()

	missingImage = image == graphics.error
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
	local opacity = self:getOpacity()
	if ( self:isVisible() and opacity ~= 0 ) then
		self:invalidate()
	end

	-- FIXME: self:animate doesn't work for gui.throbber.
	if ( self.enabled and opacity ~= 1 ) then
		self:setOpacity( math.min( opacity + dt * ( 1 / 0.4 ), 1 ) )
	elseif ( opacity ~= 0 ) then
		self:setOpacity( math.max( opacity - dt * ( 1 / 0.4 ), 0 ) )
	end
end


