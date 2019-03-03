--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: Item Grid class
--
--==========================================================================--

class "gui.itemgrid" ( "gui.box" )

local itemgrid = gui.itemgrid

function itemgrid:itemgrid( parent, name )
	gui.box.box( self, parent, name )
	self:setDisplay( "block" )
	self:setPosition( "absolute" )

	self.items   = {}
	self.columns = 0
	self.rows    = 0
end

function itemgrid:addItem( item, count )
	local itemdata = _G.item.getClass( item ).data
	local hasItem  = self:hasItem( item )
	if ( not itemdata.stackable or not hasItem ) then
		require( "game.client.gui.hudgamemenu.itembutton" )
		local itembutton = gui.itembutton( self, item )
		table.insert( self:getItems(), itembutton )
	end

	self:invalidateLayout()
end

accessor( itemgrid, "columns" )
accessor( itemgrid, "rows" )
accessor( itemgrid, "items" )

function itemgrid:hasItem( item )
	local items = self:getItems()
	for _, v in ipairs( items ) do
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

function itemgrid:removeItem( item )
	local items = self:getItems()
	for i, v in ipairs( items ) do
		if ( item == v:getItem() ) then
			table.remove( items, i )
			v:remove()
			break
		end
	end

	self:invalidateLayout()
end
