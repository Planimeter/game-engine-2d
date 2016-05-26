--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Item Grid class
--
--============================================================================--

class "itemgrid" ( gui.panel )

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

function itemgrid:getColumns()
	return self.columns
end

function itemgrid:getRows()
	return self.rows
end

function itemgrid:getItems()
	return self.items
end

function itemgrid:getSource()
	return self.source
end

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
	local columnGap = ( self:getWidth()  - columns * 44 ) / ( columns - 1 )
	local rowGap    = ( self:getHeight() - rows    * 44 ) / ( rows    - 1 )
	for n, v in pairs( items ) do
		n = n - 1
		local x  =             n % columns
		local y  = math.floor( n / columns )
		local xm = x * columnGap
		local ym = y * rowGap
		v:setPos( x * 44 + xm, y * 44 + ym )
	end
	gui.panel.invalidateLayout( self )
end

function itemgrid:setColumns( columns )
	self.columns = columns
end

function itemgrid:setRows( rows )
	self.rows = rows
end

function itemgrid:setSource( source )
	self.source = source
end

gui.register( itemgrid, "itemgrid" )
