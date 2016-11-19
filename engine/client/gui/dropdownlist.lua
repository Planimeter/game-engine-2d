--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Drop-Down List class
--
--============================================================================--

module( "gui.dropdownlist", package.class, package.inherit "gui.button" )

function dropdownlist:dropdownlist( parent, name )
	gui.button.button( self, parent, name )
	self.icon          = self:getScheme( "dropdownlist.icon" )
	self.listItemGroup = gui.dropdownlistitemgroup( self, name .. " Item Group" )
	self.active        = false
end

function dropdownlist:addItem( item )
	self:getListItemGroup():addItem( item )
end

function dropdownlist:draw()
	self:drawBackground()
	self:drawText()
	self:drawIcon()

	gui.panel.draw( self )

	self:drawForeground()
end

function dropdownlist:drawBackground()
	if ( self:isDisabled() ) then
		gui.panel.drawBackground( self, "button.disabled.backgroundColor" )
		return
	else
		gui.panel.drawBackground( self, "button.backgroundColor" )
	end

	if ( ( self.mousedown and self.mouseover ) or self:isActive() ) then
		gui.panel.drawBackground( self, "button.mousedown.backgroundColor" )
	elseif ( self.mousedown or self.mouseover ) then
		gui.panel.drawBackground( self, "button.mouseover.backgroundColor" )
	end
end

function dropdownlist:drawForeground()
	local color = "button.outlineColor"

	if ( self:isDisabled() ) then
		color = "button.disabled.outlineColor"
		gui.panel.drawForeground( self, color )
		return
	end

	if ( ( self.mousedown and self.mouseover ) or self:isActive() ) then
		color = "button.mousedown.outlineColor"
	elseif ( self.mousedown or self.mouseover or self.focus ) then
		color = "button.mouseover.outlineColor"
	end

	gui.panel.drawForeground( self, color )
end

function dropdownlist:drawIcon()
	local color = "button.textColor"

	if ( self:isDisabled() ) then
		color = "button.disabled.textColor"
	end

	graphics.setColor( self:getScheme( color ) )

	local padding = point( 18 )
	local x = self:getWidth() - self.icon:getWidth() - padding
	local y = self:getHeight() / 2 - self.icon:getHeight() / 2
	love.graphics.draw( self.icon, x, y )
end

function dropdownlist:drawText()
	local color = "button.textColor"

	if ( self:isDisabled() ) then
		color = "button.disabled.textColor"
	end

	graphics.setColor( self:getScheme( color ) )

	local font = self:getScheme( "font" )
	love.graphics.setFont( font )
	local item = self:getListItemGroup():getSelectedItem()
	local text = item and item:getText() or ""
	local x    = point( 18 )
	local y    = self:getHeight() / 2 - font:getHeight() / 2
	graphics.print( text, x, y )
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

function dropdownlist:isActive()
	return self.active
end

function dropdownlist:isChildMousedOver()
	local panel = gui.topPanel
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


