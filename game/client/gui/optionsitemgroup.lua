--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: Options Item Group class
--
--==========================================================================--

class "gui.optionsitemgroup" ( "gui.dropdownlistitemgroup" )

local optionsitemgroup = gui.optionsitemgroup

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

	self:updatePos()
end

local x, y = 0, 0

function optionsitemgroup:updatePos()
	local parent = self:getParent()
	local x, y = self:getPos()
	local width, height = self:getSize()
	if ( x + width > parent:getWidth() ) then
		x = parent:getWidth() - width
	end
	if ( y + height > parent:getHeight() ) then
		y = parent:getHeight() - height
	end
	self:setPos( x, y )
end
