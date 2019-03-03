--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Radio Button class
--
--==========================================================================--

class "gui.radiobutton" ( "gui.button" )

local radiobutton = gui.radiobutton

function radiobutton:radiobutton( parent, name, text )
	gui.button.button( self, parent, name, text )
	self:setBorderWidth( 0 )
	self.height     = 24
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
	self:drawOutline()
	self:drawLabel()

	gui.panel.draw( self )
end

function radiobutton:drawOutline()
	local color = self:getScheme( "radiobutton.borderColor" )

	if ( not self:isDisabled() ) then
		if ( self.mousedown and self.mouseover ) then
			color = self:getScheme( "radiobutton.mousedown.borderColor" )
		elseif ( self.mousedown or self.mouseover ) then
			color = self:getScheme( "radiobutton.mouseover.borderColor" )
		end
	end

	love.graphics.setColor( color )
	love.graphics.draw( self.foreground, x, y )
end

function radiobutton:drawLabel()
	if ( self:isDisabled() ) then
		love.graphics.setColor( self:getScheme( "radiobutton.disabled.textColor" ) )
	else
		love.graphics.setColor( self:getScheme( "radiobutton.textColor" ) )
	end

	local font = self:getScheme( "font" )
	love.graphics.setFont( font )
	local height = self:getHeight()
	local marginLeft = 9
	local x = math.round( height + marginLeft )
	local y = math.round( height / 2 - font:getHeight() / 2 )
	love.graphics.print( self:getText(), x, y )
end

function radiobutton:drawSelectionDot()
	if ( not self:isSelected() ) then
		return
	end

	if ( self:isDisabled() ) then
		love.graphics.setColor( self:getScheme( "radiobutton.disabled.iconColor" ) )
	else
		love.graphics.setColor( self:getScheme( "radiobutton.iconColor" ) )
	end

	local height = self:getHeight()
	local x      = height / 2 - self.icon:getWidth()  / 2
	local y      = height / 2 - self.icon:getHeight() / 2
	love.graphics.draw( self.icon, x, y )
end

accessor( radiobutton, "group" )
accessor( radiobutton, "value" )

function radiobutton:isDisabled()
	local radiobuttongroup = self:getGroup()
	if ( radiobuttongroup ) then
		return radiobuttongroup:isDisabled() or gui.button.isDisabled( self )
	end

	return gui.button.isDisabled( self )
end

gui.accessor( radiobutton, "selected", "is" )

function radiobutton:mousereleased( x, y, button, istouch )
	if ( ( self.mousedown and ( self.mouseover or self:isChildMousedOver() ) ) and not self:isDisabled() ) then
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
