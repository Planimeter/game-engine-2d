--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Checkbox class
--
--==========================================================================--

class "gui.checkbox" ( "gui.button" )

local checkbox = gui.checkbox

function checkbox:checkbox( parent, name, text )
	gui.button.button( self, parent, name, text )
	self.height  = 24
	self.icon    = self:getScheme( "checkbox.icon" )
	self.text    = text or "Checkbox Label"
	self.checked = false
end

function checkbox:draw()
	self:drawCheck()
	self:drawBorder()
	self:drawLabel()

	gui.panel.draw( self )
end

function checkbox:drawCheck()
	if ( not self:isChecked() ) then
		return
	end

	local color = self:getScheme( "checkbox.iconColor" )

	if ( self:isDisabled() ) then
		color = self:getScheme( "checkbox.disabled.iconColor" )
	end

	love.graphics.setColor( color )

	local height = self:getHeight()
	local x = height / 2 - self.icon:getWidth() / 2
	local y = height / 2 - self.icon:getHeight() / 2
	love.graphics.draw( self.icon, x, y )
end

function checkbox:drawBorder()
	local color = self:getScheme( "checkbox.borderColor" )

	if ( not self:isDisabled() ) then
		if ( self.mousedown and self.mouseover ) then
			color = self:getScheme( "checkbox.mousedown.borderColor" )
		elseif ( self.mousedown or self.mouseover or self.focus ) then
			color = self:getScheme( "checkbox.mouseover.borderColor" )
		end
	end

	love.graphics.setColor( color )
	local lineWidth = 1
	love.graphics.setLineWidth( lineWidth )
	local height = self:getHeight()
	love.graphics.rectangle(
		"line",
		lineWidth / 2,
		lineWidth / 2,
		height - lineWidth,
		height - lineWidth
	)
end

function checkbox:drawLabel()
	local color = self:getScheme( "checkbox.textColor" )

	if ( self:isDisabled() ) then
		color = self:getScheme( "checkbox.disabled.textColor" )
	end

	love.graphics.setColor( color )

	local font = self:getScheme( "font" )
	love.graphics.setFont( font )
	local height = self:getHeight()
	local marginLeft = 9
	local x = math.round( height + marginLeft )
	local y = math.round( height / 2 - font:getHeight() / 2 )
	love.graphics.print( self:getText(), x, y )
end

accessor( checkbox, "checked", "is" )

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
