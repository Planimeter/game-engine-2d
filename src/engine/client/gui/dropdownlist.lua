--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Drop-Down List class
--
--============================================================================--

class "dropdownlist" ( gui.button )

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
	local property = "button.backgroundColor"
	local width    = self:getWidth()
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

	if ( ( self.mousedown and self.mouseover ) or self:isActive() ) then
		property = "button.mousedown.backgroundColor"
		graphics.setColor( self:getScheme( property ) )
		graphics.rectangle( "fill", 0, 0, width, height )
	elseif ( self.mousedown or self.mouseover ) then
		property = "button.mouseover.backgroundColor"
		graphics.setColor( self:getScheme( property ) )
		graphics.rectangle( "fill", 0, 0, width, height )
	end
end

function dropdownlist:drawForeground()
	local property = "button.outlineColor"
	local width    = self:getWidth()
	local height   = self:getHeight()

	if ( self:isDisabled() ) then
		property = "button.disabled.outlineColor"
		graphics.setColor( self:getScheme( property ) )
		graphics.setLineWidth( 1 )
		graphics.rectangle( "line", 0, 0, width, height )
		return
	end

	if ( ( self.mousedown and self.mouseover ) or self:isActive() ) then
		property = "button.mousedown.outlineColor"
	elseif ( self.mousedown or self.mouseover ) then
		property = "button.mouseover.outlineColor"
	end

	graphics.setColor( self:getScheme( property ) )
	graphics.setLineWidth( 1 )
	graphics.rectangle( "line", 0, 0, width, height )
end

function dropdownlist:drawIcon()
	local property = "button.textColor"

	if ( self:isDisabled() ) then
		property = "button.disabled.textColor"
	end

	graphics.setColor( self:getScheme( property ) )

	local x = self:getWidth() - self.icon:getWidth() - 18
	local y = self:getHeight() / 2 - self.icon:getHeight() / 2
	graphics.draw( self.icon:getDrawable(), x, y )
end

function dropdownlist:drawText()
	local property = "button.textColor"

	if ( self:isDisabled() ) then
		property = "button.disabled.textColor"
	end

	graphics.setColor( self:getScheme( property ) )

	local font = self:getScheme( "font" )
	graphics.setFont( font )
	local item = self:getListItemGroup():getSelectedItem()
	local text = item and item:getText() or ""
	local x    = 18
	local y    = self:getHeight() / 2 - font:getHeight() / 2 - 2
	graphics.print( text, x, y )
end

function dropdownlist:getListItemGroup()
	return self.listItemGroup
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

gui.register( dropdownlist, "dropdownlist" )
