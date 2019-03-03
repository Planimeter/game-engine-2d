--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: item_gold
--
--==========================================================================--

require( "game.shared.entities.item" )
require( "game" )

class "item_gold" ( "item" )

item_gold.data = {
	name      = "Gold",
	image     = "images/entities/item_apple/1.png",
	stackable = true
}

function item_gold:item_gold()
	item.item( self )
end

if ( _CLIENT ) then
	function item_gold:pickup()
		localplayer:pickup( self )
	end

	function item_gold:drop()
		localplayer:drop( self.__type )
	end

	function item_gold:examine()
		chat.addText( "Shiny." )
	end
end

function item_gold:spawn()
	entity.spawn( self )

	local tileSize = game.tileSize
	local min      = vector()
	local max      = vector( tileSize, -tileSize )
	self:initializePhysics( "dynamic" )
	self:setCollisionBounds( min, max )
end

entities.linkToClassname( item_gold, "item_gold" )
