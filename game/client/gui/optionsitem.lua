--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: Options Item class
--
--==========================================================================--

class "gui.optionsitem" ( "gui.dropdownlistitem" )

local optionsitem = gui.optionsitem

function optionsitem:optionsitem( name, text )
	gui.dropdownlistitem.dropdownlistitem( self, name, text )
end

function optionsitem:drawText()
	local color = "button.textColor"

	if ( self:isDisabled() ) then
		color = "button.disabled.textColor"
	elseif ( self:isSelected() ) then
		color = "dropdownlistitem.selected.textColor"
	elseif ( self.mouseover ) then
		color = "dropdownlistitem.mouseover.textColor"
	end

	love.graphics.setColor( self:getScheme( color ) )

	local font = self:getScheme( "font" )
	love.graphics.setFont( font )
	local text = self:getText() .. " "
	local x = math.round( love.window.toPixels( 18 ) )
	local y = math.round( self:getHeight() / 2 - font:getHeight() / 2 )
	love.graphics.print( text, x, y )
	x = x + font:getWidth( text )
	local entity = self:getEntity()
	text = entity and entity:getName() or ""
	font = self:getScheme( "fontBold" )
	love.graphics.setFont( font )
	love.graphics.print( text, x, y )
end

accessor( optionsitem, "entity" )
