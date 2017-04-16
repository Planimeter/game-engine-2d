--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Item Grid class
--
--============================================================================--

class "gui.itemgrid" ( "gui.panel" )

local itemgrid = gui.itemgrid

function itemgrid:itemgrid( parent, name )
	gui.panel.panel( self, parent, name )
	self.items   = {}
	self.columns = 0
	self.rows    = 0

	self:setScheme( "Default" )
end

function itemgrid:addItem( item, count )
	local itemdata   = _G.item.getData( item )
	local itembutton = self:hasItem( item )
	if ( not itemdata.stackable or not itembutton ) then
		require( "game.client.gui.hudgamemenu.itembutton" )
		item = gui.itembutton( self, item )
		item:setSource( self:getSource() )
		table.insert( self:getItems(), item )
	end

	self:invalidateLayout()
end

accessor( itemgrid, "columns" )
accessor( itemgrid, "rows" )
accessor( itemgrid, "items" )
accessor( itemgrid, "source" )

function itemgrid:hasItem( item )
	local items = self:getItems()
	for _, v in pairs( items ) do
		if ( item == v:getItem() ) then
			return v
		end
	end
	return nil
end

function itemgrid:invalidateLayout()
	local items     =   self:getItems()
	local columns   =   self:getColumns()
	local rows      =   self:getRows()
	local columnGap = ( self:getWidth()  - columns * point( 44 ) ) / ( columns - 1 )
	local rowGap    = ( self:getHeight() - rows    * point( 44 ) ) / ( rows    - 1 )
	for n, v in pairs( items ) do
		n = n - 1
		local x  =             n % columns
		local y  = math.floor( n / columns )
		local xm = x * columnGap
		local ym = y * rowGap
		v:setPos( x * point( 44 ) + xm, y * point( 44 ) + ym )
	end
	gui.panel.invalidateLayout( self )
end
