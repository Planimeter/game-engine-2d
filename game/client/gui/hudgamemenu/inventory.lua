--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Game Menu Inventory class
--
--==========================================================================--

require( "game.client.gui.hudgamemenu.itemgrid" )

class "gui.hudgamemenuinventory" ( "gui.box" )

local hudgamemenuinventory = gui.hudgamemenuinventory

function hudgamemenuinventory:hudgamemenuinventory( parent )
	gui.box.box( self, parent, "Inventory" )
	self:setScheme( "Default" )
	self:setDimensions( parent:getDimensions() )

	self.grid = gui.itemgrid( self, "Inventory Item Grid" )
	self.grid:setPos( 36, 86 + 31 + 18 )
	self.grid:setDimensions( parent:getWidth() - 2 * 36, 314 )
	self.grid:setColumns( 4 )
	self.grid:setRows( 7 )

	self:addInventoryHooks()
end

function hudgamemenuinventory:addInventoryHooks()
	local function onPlayerGotItem( player, item, count )
		if ( player ~= localplayer ) then
			return
		end

		self.grid:addItem( item, count )
	end

	hook.set(
		"shared", onPlayerGotItem, "onPlayerGotItem", "updateInventory"
	)

	local function onPlayerRemovedItem( player, item, count )
		if ( player ~= localplayer ) then
			return
		end

		self.grid:removeItem( item )
	end

	hook.set(
		"shared", onPlayerRemovedItem, "onPlayerRemovedItem", "updateInventory"
	)
end

function hudgamemenuinventory:removeInventoryHooks()
	hook.remove( "shared", "onPlayerGotItem", "updateInventory" )
	hook.remove( "shared", "onPlayerRemovedItem", "updateInventory" )
end

function hudgamemenuinventory:onRemove()
	self:removeInventoryHooks()
	gui.panel.onRemove( self )
end

function hudgamemenuinventory:select( item )
	item = self.grid:hasItem( item )
	self:setSelectedItem( item )
end

accessor( hudgamemenuinventory, "selectedItem" )

function hudgamemenuinventory:setSelectedItem( item )
	if ( self.selectedItem ) then
		self.selectedItem:setSelected( false )
	end

	if ( item ) then
		item:setSelected( true )
	end

	self.selectedItem = item
end

function hudgamemenuinventory:use( item, value )
end
