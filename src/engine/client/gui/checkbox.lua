--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Checkbox class
--
--============================================================================--

class "checkbox" ( gui.button )

function checkbox:checkbox( parent, name, text )
	gui.button.button( self, parent, name, text )
	self.height	 = 24
	self.icon	 = self:getScheme( "checkbox.icon" )
	self.text	 = text or "Checkbox Label"
	self.checked = false
end

function checkbox:draw()
	if ( not self:isVisible() ) then
		return
	end

	self:drawCheck()
	self:drawForeground()
	self:drawLabel()

	gui.panel.draw( self )
end

function checkbox:drawCheck()
	if ( not self:isChecked() ) then
		return
	end

	local property = "checkbox.iconColor"

	if ( self:isDisabled() ) then
		property = "checkbox.disabled.iconColor"
	end

	graphics.setColor( self:getScheme( property ) )

	local x = 24 / 2 - self.icon:getWidth()  / 2
	local y = 24 / 2 - self.icon:getHeight() / 2
	graphics.draw( self.icon, x, y )
end

function checkbox:drawForeground()
	local property = "checkbox.outlineColor"

	if ( not self:isDisabled() ) then
		if ( self.mousedown and self.mouseover ) then
			property = "checkbox.mousedown.outlineColor"
		elseif ( self.mousedown or self.mouseover ) then
			property = "checkbox.mouseover.outlineColor"
		end
	end

	graphics.setColor( self:getScheme( property ) )
	graphics.rectangle( "line", 0, 0, 24, 24 )
end

function checkbox:drawLabel()
	local property = "checkbox.textColor"

	if ( self:isDisabled() ) then
		property = "checkbox.disabled.textColor"
	end

	graphics.setColor( self:getScheme( property ) )

	local font = self:getScheme( "font" )
	graphics.setFont( font )
	local x	= 32
	local y = self:getHeight() / 2 - font:getHeight() / 2 - 1
	graphics.print( self.text, x, y )
end

function checkbox:isChecked()
	return self.checked
end

function checkbox:mousereleased( x, y, button )
	if ( not self:isVisible() ) then
		return
	end

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
