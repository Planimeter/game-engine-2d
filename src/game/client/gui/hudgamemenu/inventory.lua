--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Game Menu Inventory class
--
--============================================================================--

require( "game.client.gui.hudgamemenu.itemgrid" )

class "hudgamemenuinventory" ( gui.panel )

function hudgamemenuinventory:hudgamemenuinventory( parent )
	gui.panel.panel( self, parent, "Inventory" )
	self:setScheme( "Default" )
	self:setSize( parent:getSize() )

	self.grid = gui.itemgrid( self, "Inventory Item Grid" )
	local margin           = point( 36 )
	local titleBarHeight   = point( 86 )
	local navigationHeight = point( 31 )
	local marginBottom     = point( 18 )
	self.grid:setPos( margin, titleBarHeight + navigationHeight + marginBottom )
	self.grid:setSize( parent:getWidth() - 2 * margin, point( 314 ) )
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
