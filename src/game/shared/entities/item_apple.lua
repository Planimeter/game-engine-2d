--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: item_apple
--
--============================================================================--

require( "game.shared.entities.item" )
require( "game" )
require( "engine.client.chat" )

class "item_apple" ( "item" )

function item_apple:item_apple()
	item.item( self )

	local tileSize = game.tileSize
	local min      = vector()
	local max      = vector( tileSize, -tileSize )
	self:setCollisionBounds( min, max )

	self:setNetworkVar( "name", "Apple" )

	if ( _CLIENT ) then
		local sprite = graphics.newImage( "images/entities/item_apple/1.png" )
		self:setSprite( sprite )
	end
end

if ( _CLIENT ) then
	function item_apple:getOptions()
		return {
			{
				name  = "Pickup",
				value = self.pickup
			},
			{
				name  = "Examine",
				value = self.examine
			}
		}
	end
end

function item_apple:pickup()
	chat.addText( "You look at the apple and attempt to pick it up, but the " ..
	              "cold reality is that your hands stay idly by your sides " ..
	              "without explanation. You fail to grasp why the physical " ..
	              "entanglement of your existence grants you access to move " ..
	              "freely about this realm but simultaneously prevents you " ..
	              "from sustaining yourself within the bounds of this " ..
	              "prison. It is not added to you inventory. Nothing " ..
	              "interesting happens." )
end

function item_apple:examine()
	chat.addText( "Looks like an apple." )
end

entities.linkToClassname( item_apple, "item_apple" )
