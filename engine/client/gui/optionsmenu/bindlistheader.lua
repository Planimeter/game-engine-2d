--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Bind List Header class
--
--============================================================================--

class "bindlistheader" ( gui.panel )

function bindlistheader:bindlistheader( parent, name, text )
	gui.panel.panel( self, parent, name )
	self.width  = parent:getWidth()
	self.height = point( 46 )
	self.text   = text or "Bind List Header"

	self:setScheme( "Default" )
end

function bindlistheader:draw()
	graphics.setColor( self:getScheme( "label.textColor" ) )
	local font = self:getScheme( "fontBold" )
	love.graphics.setFont( font )

	local margin = point( 18 )
	local x = margin
	local y = self:getHeight() / 2 - font:getHeight() / 2
	graphics.print( self:getText(), x, y )

	local label = "Key or Button"
	x = self:getWidth() - font:getWidth( label ) - margin
	graphics.print( label, x, y )

	graphics.setColor( self:getScheme( 'bindlistheader.borderColor' ) )
	local paddingBottom = point( 6 )
	y = self:getHeight() - paddingBottom
	local width = self:getWidth() - 2 * margin
	graphics.rectangle( "fill", margin, y, width, point( 1 ) )

	gui.panel.draw( self )
end

accessor( bindlistheader, "text" )

gui.register( bindlistheader, "bindlistheader" )
