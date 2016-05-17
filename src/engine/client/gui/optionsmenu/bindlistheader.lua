--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Bind List Header class
--
--============================================================================--

class "bindlistheader" ( gui.panel )

function bindlistheader:bindlistheader( parent, name, text )
	gui.panel.panel( self, parent, name )
	self.width  = parent:getWidth()
	self.height = 46
	self.text   = text or "Bind List Header"

	self:setScheme( "Default" )
end

function bindlistheader:draw()
	graphics.setColor( self:getScheme( "label.textColor" ) )
	local font = self:getScheme( "fontBold" )
	graphics.setFont( font )

	local margin = 18
	local x = margin
	local y = self:getHeight() / 2 - font:getHeight() / 2 - 2
	graphics.print( self:getText(), x, y )

	local label = "Key or Button"
	x = self:getWidth() - font:getWidth( label ) - margin
	graphics.print( label, x, y )

	graphics.setColor( self:getScheme( 'bindlistheader.borderColor' ) )
	y = self:getHeight() - 6
	local width = self:getWidth() - 2 * margin
	graphics.rectangle( "fill", margin, y, width, 1 )

	gui.panel.draw( self )
end

function bindlistheader:getText()
	return self.text
end

function bindlistheader:setText( text )
	self.text = text
end

gui.register( bindlistheader, "bindlistheader" )
