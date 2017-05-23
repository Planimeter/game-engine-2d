--=========== Copyright © 2017, Planimeter, All rights reserved. ===========--
--
-- Purpose: item_apple
--
--==========================================================================--

require( "game.shared.entities.item" )
require( "game" )

if ( _CLIENT ) then
	require( "engine.client.chat" )
end

class "item_apple" ( "item" )

item_apple.data = {
	name  = "Apple",
	image = "images/entities/item_apple/1.png"
}

function item_apple:item_apple()
	item.item( self )
end

if ( _CLIENT ) then
	function item_apple:getOptions()
		return {
			{
				name  = "Pickup",
				value = function() self:pickup() end
			},
			{
				name  = "Examine",
				value = self.examine
			}
		}
	end

	function item_apple:getInventoryOptions()
		return {
			{
				name  = "Eat",
				value = function() self:eat() end
			},
			{
				name  = "Examine",
				value = self.examine
			}
		}
	end
end

function item_apple:pickup()
	localplayer:pickup( self )
end

function item_apple:examine()
	chat.addText( "Looks like an apple." )
end

function item_apple:eat()
end

function item_apple:spawn()
	entity.spawn( self )

	local tileSize = game.tileSize
	local min      = vector()
	local max      = vector( tileSize, -tileSize )
	self:initializePhysics( "dynamic" )
	self:setCollisionBounds( min, max )
end

entities.linkToClassname( item_apple, "item_apple" )
