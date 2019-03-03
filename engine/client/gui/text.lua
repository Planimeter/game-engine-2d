--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Text class
--
--==========================================================================--

class "gui.text" ( "gui.box" )

local text = gui.text

function text:text( parent, name, text )
	gui.box.box( self, parent, name )

	local width, height = parent:getSize()
	if ( width == nil and height == nil ) then
		local font    = self:getFont()
		width, height = font:getWidth( text ), font:getHeight()
	end

	self:createFramebuffer( width, height )

	self:setText( text )
end

function text:draw()
	love.graphics.setColor( self:getColor() )
	love.graphics.setFont( self:getFont() )
	love.graphics.printf( self:getText(), 0, 0, self:getWidth() )
end

function text:getWidth()
	local font = self:getFont()
	return font:getWidth( self:getText() )
end

function text:getHeight()
	local font = self:getFont()
	return font:getHeight()
end

gui.accessor( text, "text" )

function text:getText()
	return rawget( self, "text" ) or ""
end

gui.accessor( text, "font" )

function text:getFont()
	return self.font or self:getScheme( "font" )
end
