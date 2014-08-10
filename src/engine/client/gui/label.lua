--========= Copyright © 2013-2014, Planimeter, All rights reserved. ==========--
--
-- Purpose: Label class
--
--============================================================================--

class "label" ( gui.panel )

function label:label( parent, name, text )
	gui.panel.panel( self, parent, name )
	self:setScheme( "Default" )
	local font	   = self:getScheme( "font" )
	self.width	   = 216
	self.height	   = font:getHeight()
	self.text	   = text or "Label"
	self.textAlign = "left"
end

function label:draw()
	if ( not self:isVisible() ) then
		return
	end

	graphics.setColor( self:getScheme( "label.textColor" ) )
	local font = self:getScheme( "font" )
	graphics.setFont( font )

	local align = self.textAlign
	local x		= 0

	if ( align == "left" ) then
		x = 0
	elseif ( align == "center" ) then
		x = self:getWidth() / 2 - font:getWidth( self.text ) / 2
	elseif ( align == "right" ) then
		x = self:getWidth()		- font:getWidth( self.text ) + font:getWidth( " " )
	end

	graphics.print( self.text, x, 0 )

	gui.panel.draw( self )
end

function label:getText()
	return self.text
end

function label:getTextAlign()
	return self.textAlign
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
