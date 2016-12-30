--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Console Text Box Autocomplete Item Group class
--
--============================================================================--

local gui = gui

class "gui.console.textboxautocompleteitemgroup" ( "gui.textboxautocompleteitemgroup" )

function _M:textboxautocompleteitemgroup( parent, name )
	gui.textboxautocompleteitemgroup.textboxautocompleteitemgroup( self, parent, name )
end

function _M:invalidateLayout()
	self:updatePos()

	local itemWidth = 0
	local font      = self:getScheme( "font" )
	local maxWidth  = 0
	local listItems = self:getItems()
	if ( listItems ) then
		local y = 0
		local padding = point( 18 )
		for _, listItem in ipairs( listItems ) do
			listItem:setY( y )

			itemWidth = font:getWidth( listItem:getText() ) + 2 * padding
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
