--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Game Menu Inventory class
--
--============================================================================--

require( "game.client.gui.hudgamemenu.borderlessdropdownlist" )

class "hudgamemenuinventory" ( gui.panel )

function hudgamemenuinventory:hudgamemenuinventory( parent )
	gui.panel.panel( self, parent, "Inventory" )
	self:setScheme( "Default" )
	self:setSize( parent:getSize() )

	local sort = gui.borderlessdropdownlist( self, "Sort" )
	local x = self:getWidth() - sort:getWidth() - 18
	sort:setPos( x, 36 - 14 )

	local hand = gui.dropdownlistitem( "Hand Sort", "Sort by Hand" )
	sort:addItem( hand )

	local alphabetically = gui.dropdownlistitem( "Hand Sort", "Sort Alphabetically" )
	sort:addItem( alphabetically )

	self:addInventoryHook()
end

function hudgamemenuinventory:addInventoryHook()
	local function updateInventory( player, item, count )
		self:invalidate()
	end

	hook.set( "shared", updateInventory, "onPlayerGotItem", "updateInventory" )
end

function hudgamemenuinventory:removeInventoryHook()
	hook.remove( "shared", "onPlayerGotItem", "updateInventory" )
end

function hudgamemenuinventory:draw()
	local inventory = localplayer:getInventory()
	graphics.setColor( color.white )
	graphics.setFont( self:getScheme( "consoleFont" ) )
	local y = 86 + 31 + 18
	for item, count in pairs( inventory ) do
		graphics.print( item .. " (" .. count .. ")", 36, y )
		y = y + 18
	end

	gui.panel.draw( self )
end

function hudgamemenuinventory:onRemove()
	self:removeInventoryHook()
	gui.panel.onRemove( self )
end

gui.register( hudgamemenuinventory, "hudgamemenuinventory" )
