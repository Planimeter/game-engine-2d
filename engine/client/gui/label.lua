--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Label class
--
--==========================================================================--

class "gui.label" ( "gui.box" )

local label = gui.label

function label:label( parent, name, text )
	gui.box.box( self, parent, name )
	self:setPosition( "absolute" )

	self.font   = self:getScheme( "font" )
	self.width  = 216
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

	gui.box.draw( self )
end

gui.accessor( label, "font" )
gui.accessor( label, "text" )
gui.accessor( label, "textAlign" )
