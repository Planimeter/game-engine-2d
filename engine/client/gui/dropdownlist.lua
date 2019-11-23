--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Drop-Down List class
--
--==========================================================================--

class "gui.dropdownlist" ( "gui.button" )

local dropdownlist = gui.dropdownlist

function dropdownlist:dropdownlist( parent, name )
	gui.button.button( self, parent, name )
	self.height = nil
	self:setPadding( 14, 18, 13 )
	self.icon = self:getScheme( "dropdownlist.icon" )
	self.listItemGroup = gui.dropdownlistitemgroup( self, name .. " Item Group" )
	self.active = false
end

function dropdownlist:addItem( item )
	self:getListItemGroup():addItem( item )
end

function dropdownlist:draw()
	self:drawBackground()
	self:drawText()
	self:drawIcon()

	gui.panel.draw( self )

	self:drawBorder()
end

function dropdownlist:drawBackground()
	if ( self:isDisabled() ) then
		gui.panel.drawBackground( self, self:getScheme( "button.disabled.backgroundColor" ) )
		return
	else
		gui.panel.drawBackground( self, self:getScheme( "button.backgroundColor" ) )
	end

	if ( ( self.mousedown and self.mouseover ) or self:isActive() ) then
		gui.panel.drawBackground( self, self:getScheme( "button.mousedown.backgroundColor" ) )
	elseif ( self.mousedown or self.mouseover ) then
		gui.panel.drawBackground( self, self:getScheme( "button.mouseover.backgroundColor" ) )
	end
end

function dropdownlist:drawBorder()
	local color = self:getScheme( "button.borderColor" )

	if ( self:isDisabled() ) then
		color = self:getScheme( "button.disabled.borderColor" )
		gui.panel.drawBorder( self, color )
		return
	end

	if ( ( self.mousedown and self.mouseover ) or self:isActive() ) then
		color = self:getScheme( "button.mousedown.borderColor" )
	elseif ( self.mousedown or self.mouseover or self.focus ) then
		color = self:getScheme( "button.mouseover.borderColor" )
	end

	gui.panel.drawBorder( self, color )
end

function dropdownlist:drawIcon()
	local color = self:getScheme( "button.textColor" )

	if ( self:isDisabled() ) then
		color = self:getScheme( "button.disabled.textColor" )
	end

	love.graphics.setColor( color )

	local t, r, b, l = self:getPadding()
	local x = self:getWidth() - self.icon:getWidth() - r
	local y = self:getHeight() / 2 - self.icon:getHeight() / 2
	love.graphics.draw( self.icon, x, y )
end

function dropdownlist:drawText()
	local color = self:getScheme( "button.textColor" )

	if ( self:isDisabled() ) then
		color = self:getScheme( "button.disabled.textColor" )
	end

	love.graphics.setColor( color )

	local font = self:getScheme( "font" )
	love.graphics.setFont( font )
	local item = self:getListItemGroup():getSelectedItem()
	local text = item and item:getText() or ""
	local x = math.round( 18 )
	local y = math.round( self:getHeight() / 2 - font:getHeight() / 2 )
	love.graphics.print( text, x, y )
end

accessor( dropdownlist, "listItemGroup" )

function dropdownlist:getValue()
	local listItemGroup = self:getListItemGroup()
	if ( listItemGroup ) then
		return listItemGroup:getValue()
	end
end

function dropdownlist:invalidate()
	local listItemGroup = self:getListItemGroup()
	if ( listItemGroup ) then
		listItemGroup:invalidate()
	end

	gui.panel.invalidate( self )
end

function dropdownlist:invalidateLayout()
	self:getListItemGroup():invalidateLayout()
	gui.panel.invalidateLayout( self )
end

accessor( dropdownlist, "active", "is" )

function dropdownlist:isChildMousedOver()
	local panel = gui._topPanel
	while ( panel ~= nil ) do
		panel = panel:getParent()
		if ( self:getListItemGroup() == panel ) then
			return true
		end
	end

	return false
end

function dropdownlist:keypressed( key, scancode, isrepeat )
	if ( not self.focus or self:isDisabled() ) then
		return
	end

	if ( key == "return"
	  or key == "kpenter"
	  or key == "space" ) then
		self:setActive( not self:isActive() )
		self:onClick()
	end
end

function dropdownlist:mousepressed( x, y, button, istouch )
	if ( button == 1 ) then
		if ( self.mouseover ) then
			self.mousedown = true
			self:invalidate()

			if ( not self:isDisabled() ) then
				self:setActive( not self:isActive() )
				self:onClick()
			end
		else
			if ( self:isActive() and not self:isChildMousedOver() ) then
				self:setActive( false )
			end
		end
	end
end

function dropdownlist:mousereleased( x, y, button, istouch )
	if ( self.mousedown ) then
		self.mousedown = false
		self:invalidate()
	end
end

function dropdownlist:onLostFocus()
	if ( self:isActive() ) then
		self:setActive( false )
	end
end

function dropdownlist:onValueChanged( oldValue, newValue )
end

function dropdownlist:onRemove()
	self.listItemGroup:remove()
	self.listItemGroup = nil
	gui.panel.onRemove( self )
end

function dropdownlist:setActive( active )
	self:getListItemGroup():updatePos()
	self.active = active
	gui.setFocusedPanel( self, active )
end

function dropdownlist:setValue( value )
	local listItemGroup = self:getListItemGroup()
	if ( listItemGroup ) then
		return listItemGroup:setValue( value )
	end
end
