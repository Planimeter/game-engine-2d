--========= Copyright © 2013-2014, Planimeter, All rights reserved. ==========--
--
-- Purpose: Button class
--
--============================================================================--

class "button" ( gui.panel )

button.canFocus = true

function button:button( parent, name, text )
	gui.panel.panel( self, parent, name )
	self.width	  = 216
	self.height	  = 46
	self.text	  = text or "Button"
	self.disabled = false

	self:setScheme( "Default" )
end

function button:draw()
	if ( not self:isVisible() ) then
		return
	end

	self:drawBackground()
	self:drawText()

	gui.panel.draw( self )

	self:drawForeground()
end

function button:drawBackground()
	local property = "button.backgroundColor"
	local width	   = self:getWidth()
	local height   = self:getHeight()

	if ( self:isDisabled() ) then
		property = "button.disabled.backgroundColor"
		graphics.setColor( self:getScheme( property ) )
		graphics.rectangle( "fill", 0, 0, width, height )
		return
	else
		graphics.setColor( self:getScheme( property ) )
		graphics.rectangle( "fill", 0, 0, width, height )
	end

	if ( self.mousedown and self.mouseover ) then
		property = "button.mousedown.backgroundColor"
		graphics.setColor( self:getScheme( property ) )
		graphics.rectangle( "fill", 0, 0, width, height )
	elseif ( self.mousedown or self.mouseover ) then
		property = "button.mouseover.backgroundColor"
		graphics.setColor( self:getScheme( property ) )
		graphics.rectangle( "fill", 0, 0, width, height )
	end
end

function button:drawForeground()
	local property = "button.outlineColor"
	local width	   = self:getWidth()
	local height   = self:getHeight()

	if ( self:isDisabled() ) then
		property = "button.disabled.outlineColor"
		graphics.setColor( self:getScheme( property ) )
		graphics.rectangle( "line", 0, 0, width, height )
		return
	end

	if ( self.mousedown and self.mouseover ) then
		property = "button.mousedown.outlineColor"
	elseif ( self.mousedown or self.mouseover or self.focus ) then
		property = "button.mouseover.outlineColor"
	end

	graphics.setColor( self:getScheme( property ) )
	graphics.rectangle( "line", 0, 0, width, height )
end

function button:drawText()
	local property = "button.textColor"

	if ( self:isDisabled() ) then
		property = "button.disabled.textColor"
	end

	graphics.setColor( self:getScheme( property ) )

	local font = self:getScheme( "font" )
	graphics.setFont( font )
	local x = self:getWidth()  / 2 - font:getWidth( self:getText() ) / 2
	local y = self:getHeight() / 2 - font:getHeight()				 / 2 - 2
	graphics.print( self:getText(), x, y )
end

function button:getText()
	return self.text
end

function button:isDisabled()
	return self.disabled
end

function button:keypressed( key, isrepeat )
	if ( not self:isVisible() or not self.focus or self:isDisabled() ) then
		return
	end

	if ( key == "return"
	  or key == "kpenter" ) then
		self:onClick()
	end
end

function button:mousepressed( x, y, button )
	if ( not self:isVisible() ) then
		return
	end

	if ( self.mouseover and button == "l" ) then
		self.mousedown = true
		self:invalidate()
	end
end

function button:mousereleased( x, y, button )
	if ( not self:isVisible() ) then
		return
	end

	if ( ( self.mousedown and self.mouseover ) and not self:isDisabled() ) then
		self:onClick()
	end

	if ( self.mousedown ) then
		self.mousedown = false
		self:invalidate()
	end
end

function button:onClick()
end

function button:setDisabled( disabled )
	self.disabled = disabled
	self:invalidate()
end

function button:setText( text )
	self.text = text
	self:invalidate()
end

gui.register( button, "button" )
