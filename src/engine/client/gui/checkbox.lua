--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Checkbox class
--
--============================================================================--

class "checkbox" ( gui.button )

function checkbox:checkbox( parent, name, text )
	gui.button.button( self, parent, name, text )
	self.height  = point( 24 )
	self.icon    = self:getScheme( "checkbox.icon" )
	self.text    = text or "Checkbox Label"
	self.checked = false
end

function checkbox:draw()
	self:drawCheck()
	self:drawForeground()
	self:drawLabel()

	gui.panel.draw( self )
end

function checkbox:drawCheck()
	if ( not self:isChecked() ) then
		return
	end

	local color = "checkbox.iconColor"

	if ( self:isDisabled() ) then
		color = "checkbox.disabled.iconColor"
	end

	graphics.setColor( self:getScheme( color ) )

	local height = self:getHeight()
	local x      = height / 2 - self.icon:getWidth()  / 2
	local y      = height / 2 - self.icon:getHeight() / 2
	graphics.draw( self.icon:getDrawable(), x, y )
end

function checkbox:drawForeground()
	local color = "checkbox.outlineColor"

	if ( not self:isDisabled() ) then
		if ( self.mousedown and self.mouseover ) then
			color = "checkbox.mousedown.outlineColor"
		elseif ( self.mousedown or self.mouseover or self.focus ) then
			color = "checkbox.mouseover.outlineColor"
		end
	end

	graphics.setColor( self:getScheme( color ) )
	graphics.setLineWidth( point( 1 ) )
	local height = self:getHeight()
	graphics.rectangle( "line", 0, 0, height, height )
end

function checkbox:drawLabel()
	local color = "checkbox.textColor"

	if ( self:isDisabled() ) then
		color = "checkbox.disabled.textColor"
	end

	graphics.setColor( self:getScheme( color ) )

	local font = self:getScheme( "font" )
	graphics.setFont( font )
	local height = self:getHeight()
	local marginLeft = point( 9 )
	local x = height + marginLeft
	local y = height / 2 - font:getHeight() / 2
	graphics.print( self:getText(), x, y )
end

function checkbox:isChecked()
	return self.checked
end

function checkbox:keypressed( key, scancode, isrepeat )
	if ( not self.focus or self:isDisabled() ) then
		return
	end

	if ( key == "return"
	  or key == "kpenter"
	  or key == "space" ) then
		self:onClick()
		self:setChecked( not self:isChecked() )
	end
end

function checkbox:mousereleased( x, y, button, istouch )
	if ( ( self.mousedown and self.mouseover ) and not self:isDisabled() ) then
		self:onClick()
		self:setChecked( not self:isChecked() )
	end

	if ( self.mousedown ) then
		self.mousedown = false
		self:invalidate()
	end
end

function checkbox:onCheckedChanged( checked )
end

function checkbox:setChecked( checked )
	if ( self.checked == checked ) then
		return
	end

	self.checked = checked
	self:onCheckedChanged( self.checked )
	self:invalidate()
end

gui.register( checkbox, "checkbox" )
