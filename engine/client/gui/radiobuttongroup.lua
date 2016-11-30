--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Radio Button Group class
--
--============================================================================--

local accessor = accessor
local gui      = gui
local table    = table

class "gui.radiobuttongroup" ( "gui.panel" )

function _M:radiobuttongroup( parent, name )
	gui.panel.panel( self, parent, name )
	self.selectedId = 0
	self.disabled   = false

	self:setSuppressFramebufferWarnings( true )
end

function _M:addItem( item )
	self.items =  self.items or {}
	item.id    = #self.items + 1
	table.insert( self.items, item )
	item.group = self
end

function _M:removeItem( item )
	local items = self:getItems()
	for i, v in ipairs( items ) do
		if ( v == item ) then
			table.remove( items, i )
			if ( self.selectedId == i ) then
				self.selectedId = 0
			end
			self:invalidateLayout()
		end
	end
end

accessor( _M, "items" )
accessor( _M, "selectedId" )

function _M:getSelectedItem()
	local items = self:getItems()
	if ( items ) then
		return items[ self:getSelectedId() ]
	end
end

function _M:getValue()
	local item = self:getSelectedItem()
	if ( item ) then
		return item:getValue()
	end
end

function _M:isDisabled()
	return self.disabled
end

function _M:setDisabled( disabled )
	self.disabled = disabled
end

function _M:setSelectedId( selectedId, default )
	local oldSelectedId = self:getSelectedId()
	local items         = self:getItems()
	local oldSelection  = items[ oldSelectedId ]
	local newSelection  = items[ selectedId ]
	if ( oldSelection and oldSelectedId ~= selectedId ) then
		oldSelection:setSelected( false )
		newSelection:setSelected( true )
		self.selectedId = selectedId
		self:onValueChanged( oldSelection:getValue(), newSelection:getValue() )
	else
		newSelection:setSelected( true )
		self.selectedId = selectedId
		if ( not default ) then
			self:onValueChanged( nil, newSelection:getValue() )
		end
	end
end

function _M:onValueChanged( oldValue, newValue )
end
