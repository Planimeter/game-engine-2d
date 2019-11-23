--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Console Text Box Autocomplete Item Group class
--
--==========================================================================--

class "gui.console.textboxautocompleteitemgroup" ( "gui.textboxautocompleteitemgroup" )

local textboxautocompleteitemgroup = gui.console.textboxautocompleteitemgroup

function textboxautocompleteitemgroup:textboxautocompleteitemgroup( parent, name )
	gui.textboxautocompleteitemgroup.textboxautocompleteitemgroup( self, parent, name )
end

function textboxautocompleteitemgroup:invalidateLayout()
	local itemWidth = 0
	local font      = self:getScheme( "font" )
	local maxWidth  = 0
	local listItems = self:getItems()
	if ( listItems ) then
		local y       = 1
		local padding = 18
		for _, listItem in ipairs( listItems ) do
			listItem:setX( 1 )
			listItem:setY( y )

			itemWidth = font:getWidth( listItem:getText() ) + 2 * padding
			if ( itemWidth > maxWidth ) then
				maxWidth = itemWidth
			end
			y = y + listItem:getHeight()
		end

		self:setWidth( maxWidth + 2 )
		for _, listItem in ipairs( listItems ) do
			listItem:setWidth( maxWidth )
		end
	end

	self:updatePos()
end
