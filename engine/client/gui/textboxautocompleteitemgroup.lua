--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
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
	self.textbox         = parent
end

function textboxautocompleteitemgroup:addItem( item )
	item:setParent( self )
	gui.radiobuttongroup.addItem( self, item )

	item.onClick = function( item )
		local value = item:getValue()
		self:removeChildren()
		local textbox = self:getTextbox()
		textbox:setText( value )
	end

	self:invalidateLayout()
end

accessor( textboxautocompleteitemgroup, "textbox" )

function textboxautocompleteitemgroup:invalidateLayout()
	self:updatePos()
	self:setWidth( self:getTextbox():getWidth() )

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
	local textbox     = self:getTextbox()
	local children    = self:getChildren()
	local hasChildren = children and #children > 0
	return textbox:isVisible() and textbox.focus and hasChildren
end

function textboxautocompleteitemgroup:mousepressed( x, y, button, istouch )
	if ( button == 1 ) then
		local textbox = self:getTextbox()
		if ( textbox ~= gui._topPanel and
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

function textboxautocompleteitemgroup:updatePos()
	local textbox = self:getTextbox()
	if ( textbox ) then
		local sx, sy = textbox:localToScreen()
		self:setPos( sx, sy + textbox:getHeight() )
	end
end
