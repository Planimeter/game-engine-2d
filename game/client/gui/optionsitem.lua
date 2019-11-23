--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Options Item class
--
--==========================================================================--

class "gui.optionsitem" ( "gui.dropdownlistitem" )

local optionsitem = gui.optionsitem

function optionsitem:optionsitem( parent, name, text )
	gui.dropdownlistitem.dropdownlistitem( self, parent, name, text .. " " )
	self.entityText = gui.text( self, "" )
	self.entityText:setFont( self:getScheme( "fontBold" ) )
end

function optionsitem:drawText()
	local color = self:getScheme( "button.textColor" )

	if ( self:isDisabled() ) then
		color = self:getScheme( "button.disabled.textColor" )
	elseif ( self:isSelected() ) then
		color = self:getScheme( "dropdownlistitem.selected.textColor" )
	elseif ( ( self.mouseover or self:isChildMousedOver() ) ) then
		color = self:getScheme( "dropdownlistitem.mouseover.textColor" )
	end

	self.text:setColor( color )
	self.entityText:setColor( color )

	local entity = self:getEntity()
	local text = ""
	if ( type( entity ) == "string" ) then
		text = entity
	else
		text = entity and entity:getName() or ""
	end
	self.entityText:set( text )
end

function optionsitem:setDefault( default )
end

function optionsitem:setSelected( selected )
end

accessor( optionsitem, "entity" )
