--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
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
	self:updatePos()

	local itemWidth = 0
	local font      = self:getScheme( "font" )
	local maxWidth  = 0
	local listItems = self:getItems()
	if ( listItems ) then
		local y       = 0
		local padding = love.window.toPixels( 18 )
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
