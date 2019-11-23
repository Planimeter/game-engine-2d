--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Checkbox class
--
--==========================================================================--

class "gui.checkbox" ( "gui.button" )

local checkbox = gui.checkbox

function checkbox:checkbox( parent, name, text )
	gui.button.button( self, parent, name, text )
	self.width  = nil
	self.height = nil
	self:setPadding( 4, 0, 3 )
	self:setBorderWidth( 0 )
	self.text:setDisplay( "inline-block" )
	self.text:set( text )
	self.text:setMarginLeft( 34 )
	self.icon    = self:getScheme( "checkbox.icon" )
	self.checked = false
end

function checkbox:draw()
	self:drawCheck()
	self:drawBorder()
	self:drawLabel()

	gui.box.draw( self )
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
	local x = math.round( height / 2 - self.icon:getWidth() / 2 )
	local y = math.round( height / 2 - self.icon:getHeight() / 2 )
	love.graphics.draw( self.icon, x, y )
end

function checkbox:drawBorder()
	local mouseover = ( self.mouseover or self:isChildMousedOver() )
	local color = self:getScheme( "checkbox.borderColor" )

	if ( not self:isDisabled() ) then
		if ( self.mousedown and mouseover ) then
			color = self:getScheme( "checkbox.mousedown.borderColor" )
		elseif ( self.mousedown or mouseover or self.focus ) then
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

	self.text:setColor( color )
end

accessor( checkbox, "checked", "is" )

function checkbox:keypressed( key, scancode, isrepeat )
	if ( not self.focus or self:isDisabled() ) then
		return
	end

	if ( key == "return"
	  or key == "kpenter"
	  or key == "space" ) then
		self:setChecked( not self:isChecked() )
		self:onClick()
	end
end

function checkbox:mousereleased( x, y, button, istouch )
	local mouseover = ( self.mouseover or self:isChildMousedOver() )
	if ( ( self.mousedown and mouseover ) and not self:isDisabled() ) then
		self:setChecked( not self:isChecked() )
		self:onClick()
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
