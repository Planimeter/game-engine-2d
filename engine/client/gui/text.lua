--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Text class
--
--==========================================================================--

class "gui.text" ( "gui.box" )

local text = gui.text

function text:text( parent, text )
	gui.box.box( self, parent, nil )
	self:set( text )
end

function text:createCanvas()
end

function text:draw()
	assert( false )
	love.graphics.setColor( self:getColor() )
	love.graphics.draw( self._text )
end

function text:drawCanvas()
	if ( not self:isVisible() ) then
		return
	end

	love.graphics.push()
		local a = self:getOpacity()
		local c = self:getColor()
		love.graphics.setColor(
			a * c[ 1 ], a * c[ 2 ], a * c[ 3 ], a * c[ 4 ]
		)
		love.graphics.draw( self._text )
	love.graphics.pop()
end

function text:getWidth()
	local font = self:getFont()
	return font:getWidth( self:get() )
end

function text:getHeight()
	local font = self:getFont()
	return font:getHeight()
end

function text:set( text )
	self.text = text

	if ( self._text ) then
		self._text:set( text or "" )
	else
		self._text = love.graphics.newText( self:getFont(), text )
	end
end

text.setText = text.set

function text:get()
	return rawget( self, "text" ) or ""
end

function text:setFont( font )
	self._text:setFont( font )
end

function text:getFont()
	return self._text and self._text:getFont() or self:getScheme( "font" )
end
