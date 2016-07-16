--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Radio Button class
--
--============================================================================--

class "radiobutton" ( gui.button )

function radiobutton:radiobutton( parent, name, text )
	gui.button.button( self, parent, name, text )
	self.height     = point( 24 )
	self.icon       = self:getScheme( "radiobutton.icon" )
	self.foreground = self:getScheme( "radiobutton.foreground" )
	self.text       = text or "Radio Button Label"
	self.value      = nil
	self.selected   = false
	self.id         = -1
	self.default    = false
end

function radiobutton:draw()
	self:drawSelectionDot()
	self:drawForeground()
	self:drawLabel()

	gui.panel.draw( self )
end

function radiobutton:drawForeground()
	local color = "radiobutton.outlineColor"

	if ( not self:isDisabled() ) then
		if ( self.mousedown and self.mouseover ) then
			color = "radiobutton.mousedown.outlineColor"
		elseif ( self.mousedown or self.mouseover ) then
			color = "radiobutton.mouseover.outlineColor"
		end
	end

	graphics.setColor( self:getScheme( color ) )
	graphics.draw( self.foreground:getDrawable(), x, y )
end

function radiobutton:drawLabel()
	if ( self:isDisabled() ) then
		graphics.setColor( self:getScheme( "radiobutton.disabled.textColor" ) )
	else
		graphics.setColor( self:getScheme( "radiobutton.textColor" ) )
	end

	local font = self:getScheme( "font" )
	graphics.setFont( font )
	local height = self:getHeight()
	local marginLeft = point( 9 )
	local x = height + marginLeft
	local y = height / 2 - font:getHeight() / 2
	graphics.print( self:getText(), x, y )
end

function radiobutton:drawSelectionDot()
	if ( not self:isSelected() ) then
		return
	end

	if ( self:isDisabled() ) then
		graphics.setColor( self:getScheme( "radiobutton.disabled.iconColor" ) )
	else
		graphics.setColor( self:getScheme( "radiobutton.iconColor" ) )
	end

	local height = self:getHeight()
	local x      = height / 2 - self.icon:getWidth()  / 2
	local y      = height / 2 - self.icon:getHeight() / 2
	graphics.draw( self.icon:getDrawable(), x, y )
end

accessor( radiobutton, "group" )
mutator( radiobutton, "value" )

function radiobutton:isDisabled()
	local radiobuttongroup = self:getGroup()
	if ( radiobuttongroup ) then
		return radiobuttongroup:isDisabled() or gui.button.isDisabled( self )
	end

	return gui.button.isDisabled( self )
end

function radiobutton:isSelected()
	return self.selected
end

function radiobutton:mousereleased( x, y, button, istouch )
	if ( ( self.mousedown and self.mouseover ) and not self:isDisabled() ) then
		local radiobuttongroup = self:getGroup()
		if ( radiobuttongroup ) then
			radiobuttongroup:setSelectedId( self.id )
			self:onClick()
		end
	end

	if ( self.mousedown ) then
		self.mousedown = false
		self:invalidate()
	end
end

function radiobutton:remove()
	local group = self:getGroup()
	if ( group ) then
		group:removeItem( self )
	end

	gui.panel.remove( self )
end

function radiobutton:setDefault( default )
	self.default = default

	local radiobuttongroup = self:getGroup()
	if ( default and radiobuttongroup ) then
		radiobuttongroup:setSelectedId( self.id, default )
	end
end

function radiobutton:setSelected( selected )
	self.selected = selected
	self:invalidate()
end

gui.register( radiobutton, "radiobutton" )
