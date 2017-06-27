--=========== Copyright © 2017, Planimeter, All rights reserved. ===========--
--
-- Purpose: Label class
--
--==========================================================================--

class "gui.label" ( "gui.panel" )

local label = gui.label

function label:label( parent, name, text )
	gui.panel.panel( self, parent, name )
	self:setScheme( "Default" )
	self.font   = self:getScheme( "font" )
	self.width  = love.window.toPixels( 216 )
	self.height = self.font:getHeight()
	self.text   = text or "Label"
end

function label:draw()
	love.graphics.setColor( self:getScheme( "label.textColor" ) )

	local font  = self:getFont()
	love.graphics.setFont( font )

	local text  = self:getText()
	local limit = self:getWidth()
	local align = self:getTextAlign()
	love.graphics.printf( text, 0, 0, limit, align )

	gui.panel.draw( self )
end

accessor( label, "font" )
accessor( label, "text" )
accessor( label, "textAlign" )

function label:setFont( font )
	self.font = font
	self:invalidate()
end

function label:setText( text )
	self.text = text
	self:invalidate()
end

function label:setTextAlign( textAlign )
	self.textAlign = textAlign
	self:invalidate()
end
