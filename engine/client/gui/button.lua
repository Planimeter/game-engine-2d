--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: Button class
--
--==========================================================================--

class "gui.button" ( "gui.box" )

local button = gui.button

button.canFocus = true

function button:button( parent, name, text )
	gui.box.box( self, parent, name )
	self:setDisplay( "block" )
	self:setPosition( "absolute" )
	self:setBorderWidth( 1 )
	self.width    = 216
	self.height   = 46
	self.text     = text or "Button"
	self.disabled = false

	self:setScheme( "Default" )
end

function button:draw()
	self:drawBackground()
	self:drawText()

	gui.box.draw( self )
end

function button:drawBorder()
	local color = self:getScheme( "button.borderColor" )

	if ( self:isDisabled() ) then
		color = self:getScheme( "button.disabled.borderColor" )
		gui.box.drawBorder( self, color )
		return
	end

	if ( self.mousedown and ( self.mouseover or self:isChildMousedOver() ) ) then
		color = self:getScheme( "button.mousedown.borderColor" )
	elseif ( self.mousedown or ( self.mouseover or self:isChildMousedOver() ) or self.focus ) then
		color = self:getScheme( "button.mouseover.borderColor" )
	end

	gui.box.drawBorder( self, color )
end

function button:drawText()
	local color = self:getScheme( "button.textColor" )

	if ( self:isDisabled() ) then
		color = self:getScheme( "button.disabled.textColor" )
	end

	love.graphics.setColor( color )

	local font = self:getScheme( "font" )
	love.graphics.setFont( font )
	local text = self:getText()
	local x = math.round( self:getWidth() / 2 - font:getWidth( text ) / 2 )
	local y = math.round( self:getHeight() / 2 - font:getHeight() / 2 )
	love.graphics.print( text, x, y )
end

gui.accessor( button, "text" )
gui.accessor( button, "disabled", "is" )

function button:keypressed( key, scancode, isrepeat )
	if ( not self.focus or self:isDisabled() ) then
		return
	end

	if ( key == "return"
	  or key == "kpenter"
	  or key == "space" ) then
		self:onClick()
	end
end

function button:mousepressed( x, y, button, istouch )
	if ( ( self.mouseover or self:isChildMousedOver() ) and button == 1 ) then
		self.mousedown = true
		self:invalidate()
	end
end

function button:mousereleased( x, y, button, istouch )
	if ( ( self.mousedown and ( self.mouseover or self:isChildMousedOver() ) ) and not self:isDisabled() ) then
		self:onClick()
	end

	if ( self.mousedown ) then
		self.mousedown = false
		self:invalidate()
	end
end

function button:onClick()
end

function button:setText( text )
	if ( type( self.text ) ~= "string" ) then
		self.text:setText( text )
	else
		self.text = text
	end
	self:invalidate()
end

function button:getText()
	if ( type( self.text ) ~= "string" ) then
		return self.text:getText()
	else
		return self.text
	end
end
