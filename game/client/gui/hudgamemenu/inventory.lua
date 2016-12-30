--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Game Menu Inventory class
--
--============================================================================--

require( "game.client.gui.hudgamemenu.itemgrid" )

class "gui.hudgamemenuinventory" ( "gui.panel" )

function hudgamemenuinventory:hudgamemenuinventory( parent )
	gui.panel.panel( self, parent, "Inventory" )
	self:setScheme( "Default" )
	self:setSize( parent:getSize() )

	self.grid = gui.itemgrid( self, "Inventory Item Grid" )
	self.grid:setPos( point( 36 ), point( 86 + 31 + 18 ) )
	self.grid:setSize( parent:getWidth() - 2 * point( 36 ), point( 314 ) )
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


