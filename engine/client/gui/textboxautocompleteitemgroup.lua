--=========== Copyright © 2017, Planimeter, All rights reserved. ===========--
--
-- Purpose: Text Box Autocomplete Item Group class
--
--==========================================================================--

local gui = gui

class "gui.textboxautocompleteitemgroup" ( "gui.dropdownlistitemgroup" )

local textboxautocompleteitemgroup = gui.textboxautocompleteitemgroup

function textboxautocompleteitemgroup:textboxautocompleteitemgroup( parent, name )
	gui.dropdownlistitemgroup.dropdownlistitemgroup( self, parent, name )
	-- UNDONE: The drop-down list field is reserved for the control responsible
	-- for the drop-down list item group. The control does not necessarily have
	-- to be a dropdownlist.
	-- self.dropDownList = nil
	self.textBox         = parent

	self:setSuppressFramebufferWarnings( true )
end

function textboxautocompleteitemgroup:addItem( item )
	item:setParent( self )
	gui.radiobuttongroup.addItem( self, item )

	item.onClick = function( item )
		local value = item:getValue()
		self:removeChildren()
		local textBox = self:getTextBox()
		textBox:setText( value )
	end

	self:invalidateLayout()
end

function textboxautocompleteitemgroup:getTextBox()
	return self.textBox
end

function textboxautocompleteitemgroup:invalidateLayout()
	self:updatePos()
	self:setWidth( self:getTextBox():getWidth() )

	local listItems = self:getItems()
	if ( listItems ) then
		local y = 0
		for _, listItem in ipairs( listItems ) do
			listItem:setY( y )
			listItem:setWidth( self:getWidth() )
			y = y + listItem:getHeight()
		end
		self:setHeight( y )
	end
end

function textboxautocompleteitemgroup:isVisible()
	local textBox     = self:getTextBox()
	local children    = self:getChildren()
	local hasChildren = children and #children > 0
	return textBox:isVisible() and textBox.focus and hasChildren
end

function textboxautocompleteitemgroup:mousepressed( x, y, button, istouch )
	if ( button == 1 ) then
		local textBox = self:getTextBox()
		if ( textBox ~= gui._topPanel and
		   ( not ( self.mouseover or self:isChildMousedOver() ) ) ) then
			if ( self:getChildren() ) then
				self:removeChildren()
			end
		end
	end

	return gui.panel.mousepressed( self, x, y, button, istouch )
end

function textboxautocompleteitemgroup:onValueChanged( oldValue, newValue )
end

local sx, sy = 0, 0

function textboxautocompleteitemgroup:updatePos()
	local textBox = self:getTextBox()
	if ( textBox ) then
		sx, sy = textBox:localToScreen()
		self:setPos( sx, sy + textBox:getHeight() )
	end
end
