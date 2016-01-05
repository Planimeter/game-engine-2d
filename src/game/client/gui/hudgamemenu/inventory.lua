--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Game Menu Inventory class
--
--============================================================================--

require( "game.client.gui.hudgamemenu.borderlessdropdownlist" )
require( "game.client.gui.hudgamemenu.itemgrid" )

class "hudgamemenuinventory" ( gui.panel )

function hudgamemenuinventory:hudgamemenuinventory( parent )
	gui.panel.panel( self, parent, "Inventory" )
	self:setScheme( "Default" )
	self:setSize( parent:getSize() )

	-- local sort = gui.borderlessdropdownlist( self, "Sort" )
	-- local x = self:getWidth() - sort:getWidth() - 18
	-- sort:setPos( x, 36 - 14 )
	-- sort:setDisabled( true )
	--
	-- local hand = gui.dropdownlistitem( "Hand Sort", "Sort by Hand" )
	-- sort:addItem( hand )
	--
	-- local alphabetically = gui.dropdownlistitem( "Hand Sort", "Sort Alphabetically" )
	-- sort:addItem( alphabetically )

	self.grid = gui.itemgrid( self, "Inventory Item Grid" )
	self.grid:setPos( 36, 86 + 31 + 18 )
	self.grid:setSize( parent:getWidth() - 2 * 36, 314 )
	self.grid:setColumns( 4 )
	self.grid:setRows( 7 )

	self:addInventoryHook()
end

function hudgamemenuinventory:addInventoryHook()
	local function updateInventory( player, item, count )
		self.grid:addItem( item, count )
		self.grid:invalidate()
	end

	hook.set( "shared", updateInventory, "onPlayerGotItem", "updateInventory" )
end

function hudgamemenuinventory:removeInventoryHook()
	hook.remove( "shared", "onPlayerGotItem", "updateInventory" )
end

function hudgamemenuinventory:onRemove()
	self:removeInventoryHook()
	gui.panel.onRemove( self )
end

gui.register( hudgamemenuinventory, "hudgamemenuinventory" )
