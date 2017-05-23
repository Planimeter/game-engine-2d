--=========== Copyright © 2017, Planimeter, All rights reserved. ===========--
--
-- Purpose: Frame Tab class
--
--==========================================================================--

class "gui.frametab" ( "gui.radiobutton" )

local frametab = gui.frametab

function frametab:frametab( parent, name, text )
	gui.radiobutton.radiobutton( self, parent, name, text )
	self.text     = text or "Frame Tab"
	local font    = self:getScheme( "font" )
	local padding = point( 24 )
	self.width    = font:getWidth( self:getText() ) + 2 * padding
	self.height   = point( 61 )
end

function frametab:draw()
	self:drawBackground()
	self:drawText()

	gui.panel.draw( self )
end

function frametab:drawBackground()
	local color  = "frametab.backgroundColor"
	local width  = self:getWidth()
	local height = self:getHeight()

	if ( self:isSelected() ) then
		color = "frametab.selected.backgroundColor"
	elseif ( self.mouseover ) then
		gui.panel.drawBackground( self, color )
		color = "frametab.mouseover.backgroundColor"
	end

	love.graphics.setColor( self:getScheme( color ) )

	local selected  = self.mouseover or      self:isSelected()
	local mouseover = self.mouseover and not self:isSelected()
	love.graphics.rectangle(
		"fill",
		0,
		0,
		width  - ( selected  and point( 1 ) or 0 ),
		height - ( mouseover and point( 1 ) or 0 )
	)

	local lineWidth = point( 1 )
	if ( selected ) then
		love.graphics.setColor( self:getScheme( "frametab.backgroundColor" ) )
		love.graphics.line(
			width - lineWidth / 2, 0,     -- Top-left
			width - lineWidth / 2, height -- Bottom-left
		)
	end

	selected = self:isSelected()
	love.graphics.setColor( self:getScheme( "frametab.outlineColor" ) )
	love.graphics.line(
		width - lineWidth / 2, 0,
		width - lineWidth / 2, height - ( selected and 0 or point( 1 ) )
	)

	if ( not selected ) then
		love.graphics.line(
			0,     height - lineWidth / 2, -- Top-right
			width, height - lineWidth / 2  -- Bottom-right
		)
	end
end

function frametab:mousepressed( x, y, button, istouch )
	if ( self.mouseover and button == 1 ) then
		self.mousedown = true

		if ( not self:isDisabled() ) then
			local frametabgroup = self:getGroup()
			if ( frametabgroup ) then
				frametabgroup:setSelectedId( self.id )
				self:onClick()
			end
		end
	end

	self:invalidate()
end

function frametab:mousereleased( x, y, button, istouch )
	self.mousedown = false
	self:invalidate()
end
