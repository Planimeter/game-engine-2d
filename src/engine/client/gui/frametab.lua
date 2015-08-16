--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Frame Tab class
--
--============================================================================--

class "frametab" ( gui.radiobutton )

function frametab:frametab( parent, name, text )
	gui.radiobutton.radiobutton( self, parent, name, text )
	self.text   = text or "Frame Tab"
	local font  = self:getScheme( "font" )
	self.width  = font:getWidth( self.text ) + 2 * 24
	self.height = 61
end

function frametab:draw()
	self:drawBackground()
	self:drawText()

	gui.panel.draw( self )
end

function frametab:drawBackground()
	local property = "frametab.backgroundColor"
	local width    = self:getWidth()
	local height   = self:getHeight()

	if ( self:isSelected() ) then
		property = "frametab.selected.backgroundColor"
	elseif ( self.mouseover ) then
		graphics.setColor( self:getScheme( property ) )
		graphics.rectangle( "fill", 0, 0, width, height )
		property = "frametab.mouseover.backgroundColor"
	end

	graphics.setColor( self:getScheme( property ) )

	local selected  = self.mouseover or self:isSelected()
	local mouseover = self.mouseover and not self:isSelected()
	graphics.rectangle( "fill",
	                    0,
	                    -1,
	                    width - ( selected and 1 or 0 ),
	                    height + 1 - ( mouseover and 1 or 0 ) )

	width = width - 0.5
	if ( selected ) then
		graphics.setColor( self:getScheme( "frametab.backgroundColor" ) )
		graphics.line( width, -0.5, width, height - 0.5 )
	end

	graphics.setColor( self:getScheme( "frametab.outlineColor" ) )
	graphics.line( width, -0.5,
	               width, height - 0.5 - ( self:isSelected() and 0 or 1 ) )

	if ( not self:isSelected() ) then
		graphics.line( 0, height - 1, width, height - 1 )
	end
end

function frametab:drawText()
	local property = "button.textColor"

	if ( self:isDisabled() ) then
		property = "button.disabled.textColor"
	end

	graphics.setColor( self:getScheme( property ) )

	local font = self:getScheme( "font" )
	graphics.setFont( font )
	local x = self:getWidth()  / 2 - font:getWidth( self.text ) / 2
	local y = self:getHeight() / 2 - font:getHeight()           / 2
	graphics.print( self.text, x, y )
end

function frametab:mousepressed( x, y, button )
	if ( self.mouseover and button == "l" ) then
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

function frametab:mousereleased( x, y, button )
	self.mousedown = false
	self:invalidate()
end

gui.register( frametab, "frametab" )
