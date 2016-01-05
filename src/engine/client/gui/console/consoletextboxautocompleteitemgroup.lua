--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Console Text Box Autocomplete Item Group class
--
--============================================================================--

class "consoletextboxautocompleteitemgroup" ( gui.textboxautocompleteitemgroup )

function consoletextboxautocompleteitemgroup:consoletextboxautocompleteitemgroup( parent, name )
	gui.textboxautocompleteitemgroup.textboxautocompleteitemgroup( self, parent, name )
end

function consoletextboxautocompleteitemgroup:invalidateLayout()
	self:updatePos()

	local itemWidth = 0
	local font      = self:getScheme( "font" )
	local maxWidth  = 0
	local listItems = self:getItems()
	if ( listItems ) then
		local y = 0
		for _, listItem in ipairs( listItems ) do
			listItem:setY( y )

			itemWidth = font:getWidth( listItem:getText() ) + 2 * 18
			if ( itemWidth > maxWidth ) then
				maxWidth = itemWidth
			end
			y = y + listItem:getHeight()
		end

		self:setWidth( maxWidth )
		for _, listItem in ipairs( listItems ) do
			listItem:setWidth( maxWidth )
		end

		self:setHeight( y )
	end
end

gui.register( consoletextboxautocompleteitemgroup, "consoletextboxautocompleteitemgroup" )
