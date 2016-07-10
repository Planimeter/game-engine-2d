--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Label class
--
--============================================================================--

class "label" ( gui.panel )

function label:label( parent, name, text )
	gui.panel.panel( self, parent, name )
	self:setScheme( "Default" )
	self.font      = self:getScheme( "font" )
	self.width     = point( 216 )
	self.height    = self.font:getHeight()
	self.text      = text or "Label"
	self.textAlign = "left"
end

function label:draw()
	graphics.setColor( self:getScheme( "label.textColor" ) )

	local font = self:getFont()
	graphics.setFont( font )

	local align     = self.textAlign
	local text      = self:getText()
	local textWidth = font:getWidth( text )
	local x         = 0

	if ( align == "left" ) then
		x = 0
	elseif ( align == "center" ) then
		x = self:getWidth() / 2 - textWidth / 2
	elseif ( align == "right" ) then
		x = self:getWidth()     - textWidth + font:getWidth( " " )
	end

	graphics.print( text, x, 0 )

	gui.panel.draw( self )
end

function label:getFont()
	return self.font
end

function label:getText()
	return self.text
end

function label:getTextAlign()
	return self.textAlign
end

function label:setFont( font )
	self.font = font
end

function label:setText( text )
	self.text = text
	self:invalidate()
end

function label:setTextAlign( textAlign )
	self.textAlign = textAlign
	self:invalidate()
end

gui.register( label, "label" )
