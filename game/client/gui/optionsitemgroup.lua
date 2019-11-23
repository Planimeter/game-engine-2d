--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
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

	-- self:setParent( parent )
end

function optionsitemgroup:addItem( item )
	item:setParent( self )
	gui.radiobuttongroup.addItem( self, item )

	item.onClick = function( item )
		local value = item:getValue()
		value()
	end

	self:invalidateLayout()
end

function optionsitemgroup:invalidateLayout()
	self:updatePos()
	gui.panel.invalidateLayout( self )
end

function optionsitemgroup:updatePos()
	local parent = self:getParent()
	local x, y = self:getPos()
	local width, height = self:getDimensions()
	local windowPadding = 4
	if ( x + width > parent:getWidth() ) then
		x = x - width
	end

	local overflow = y + height
	if ( overflow > parent:getHeight() - windowPadding ) then
		overflow = overflow - parent:getHeight() + windowPadding
		y = y - overflow
	end

	if ( y < windowPadding ) then
		y = windowPadding
	end

	self:setPos( x, y )
end
