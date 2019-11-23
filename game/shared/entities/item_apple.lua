--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: item_apple
--
--==========================================================================--

require( "game.shared.entities.item" )
require( "game" )

class "item_apple" ( "item" )

item_apple.data = {
	name  = "Apple",
	image = "images/entities/item_apple/1.png"
}

function item_apple:item_apple()
	item.item( self )
end

if ( _CLIENT ) then
	function item_apple:getInventoryOptions()
		return {
			{ name = "Eat",     value = function() self:eat()        end },
			{
				name  = "Use",
				value = function()
					g_Inventory:select( self.__type )
				end
			},
			{ name = "Drop",    value = function() item.drop( self ) end },
			{ name = "Examine", value = function() self:examine()    end }
		}
	end

	function item_apple:examine()
		chat.addText( "Looks like an apple." )
	end

	function item_apple:eat()
		localplayer:useItem( self.__type )
	end
end

function item_apple:spawn()
	entity.spawn( self )

	local tileSize = game.tileSize
	local min      = vector()
	local max      = vector( tileSize, -tileSize )
	self:initializePhysics( "dynamic" )
	self:setCollisionBounds( min, max )

	local body = self:getBody()
	if ( body ) then
		body:setMass( 0.1496855 )
	end
end

function item_apple:useItem( activator, value )
	-- Give health
	local health = activator:getNetworkVar( "health" )
	activator:setNetworkVar( "health", health + 3 )

	-- Notify player
	activator:sendText( "The apple gives you some health." )

	-- Remove from inventory
	activator:removeItem( self.__type )
end

entities.linkToClassname( item_apple, "item_apple" )
