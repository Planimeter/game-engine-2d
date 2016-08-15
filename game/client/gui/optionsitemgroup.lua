--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Options Item Group class
--
--============================================================================--

class "optionsitemgroup" ( gui.dropdownlistitemgroup )

function optionsitemgroup:optionsitemgroup( parent, name )
	gui.dropdownlistitemgroup.dropdownlistitemgroup( self, parent, name )
	-- UNDONE: The drop-down list field is reserved for the control responsible
	-- for the drop-down list item group. The control does not necessarily have
	-- to be a dropdownlist.
	-- self.dropDownList = nil

	self:setSuppressFramebufferWarnings( true )
	self:setParent( parent )
end

function optionsitemgroup:addItem( item )
	item:setParent( self )
	gui.radiobuttongroup.addItem( self, item )

	item.onClick = function( item )
		local value = item:getValue()
		self:removeChildren()
		value()
	end

	self:invalidateLayout()
end

function optionsitemgroup:invalidateLayout()
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

gui.register( optionsitemgroup, "optionsitemgroup" )
