--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Bind List Header class
--
--==========================================================================--

class "gui.bindlistheader" ( "gui.panel" )

local bindlistheader = gui.bindlistheader

function bindlistheader:bindlistheader( parent, name, text )
	gui.panel.panel( self, parent, name )
	self.width  = parent:getWidth()
	self.height = 46
	self.text   = text or "Bind List Header"

	self:setScheme( "Default" )
end

function bindlistheader:draw()
	love.graphics.setColor( self:getScheme( "label.textColor" ) )
	local font = self:getScheme( "fontBold" )
	love.graphics.setFont( font )

	local margin   = 18
	local x        = math.round( margin )
	local y        = math.round( self:getHeight() / 2 - font:getHeight() / 2 )
	love.graphics.print( self:getText(), x, y )

	local label = "Key or Button"
	x = math.round( self:getWidth() - margin - font:getWidth( label ) )
	love.graphics.print( label, x, y )

	love.graphics.setColor( self:getScheme( 'bindlistheader.borderColor' ) )
	x            = margin
	y            = self:getHeight() - 6 -- Padding-bottom
	local width  = self:getWidth() - 2 * margin
	local height = 1
	love.graphics.rectangle( "fill", x, y, width, height )

	gui.panel.draw( self )
end

accessor( bindlistheader, "text" )
