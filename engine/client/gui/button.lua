--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Button class
--
--============================================================================--

class "gui.button" ( "gui.panel" )

local button = gui.button

button.canFocus = true

function button:button( parent, name, text )
	gui.panel.panel( self, parent, name )
	self.width    = point( 216 )
	self.height   = point( 46 )
	self.text     = text or "Button"
	self.disabled = false

	self:setScheme( "Default" )
end

function button:draw()
	self:drawBackground()
	self:drawText()

	gui.panel.draw( self )

	self:drawForeground()
end

function button:drawBackground()
	if ( self:isDisabled() ) then
		gui.panel.drawBackground( self, "button.disabled.backgroundColor" )
		return
	else
		gui.panel.drawBackground( self, "button.backgroundColor" )
	end

	if ( self.mousedown and self.mouseover ) then
		gui.panel.drawBackground( self, "button.mousedown.backgroundColor" )
	elseif ( self.mousedown or self.mouseover ) then
		gui.panel.drawBackground( self, "button.mouseover.backgroundColor" )
	end
end

function button:drawForeground()
	local color = "button.outlineColor"

	if ( self:isDisabled() ) then
		color = "button.disabled.outlineColor"
		gui.panel.drawForeground( self, color )
		return
	end

	if ( self.mousedown and self.mouseover ) then
		color = "button.mousedown.outlineColor"
	elseif ( self.mousedown or self.mouseover or self.focus ) then
		color = "button.mouseover.outlineColor"
	end

	gui.panel.drawForeground( self, color )
end

function button:drawText()
	local color = "button.textColor"

	if ( self:isDisabled() ) then
		color = "button.disabled.textColor"
	end

	love.graphics.setColor( self:getScheme( color ) )

	local font = self:getScheme( "font" )
	love.graphics.setFont( font )
	local text = self:getText()
	local x = self:getWidth() / 2 - font:getWidth( text ) / 2
	local y = self:getHeight() / 2 - font:getHeight() / 2
	graphics.print( text, x, y )
end

accessor( button, "text" )

function button:isDisabled()
	return self.disabled
end

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
	if ( self.mouseover and button == 1 ) then
		self.mousedown = true
		self:invalidate()
	end
end

function button:mousereleased( x, y, button, istouch )
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
