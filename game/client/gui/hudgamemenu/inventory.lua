--=========== Copyright © 2017, Planimeter, All rights reserved. ===========--
--
-- Purpose: Game Menu Inventory class
--
--==========================================================================--

require( "game.client.gui.hudgamemenu.itemgrid" )

class "gui.hudgamemenuinventory" ( "gui.panel" )

local hudgamemenuinventory = gui.hudgamemenuinventory

function hudgamemenuinventory:hudgamemenuinventory( parent )
	gui.panel.panel( self, parent, "Inventory" )
	self:setScheme( "Default" )
	self:setSize( parent:getSize() )

	self.grid = gui.itemgrid( self, "Inventory Item Grid" )
	self.grid:setPos( love.window.toPixels( 36 ), love.window.toPixels( 86 + 31 + 18 ) )
	self.grid:setSize( parent:getWidth() - 2 * love.window.toPixels( 36 ), love.window.toPixels( 314 ) )
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
