--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: weapon_bow
--
--==========================================================================--

require( "game.shared.entities.item" )
require( "game" )

if ( _CLIENT ) then
	require( "engine.client.chat" )
end

class "weapon_bow" ( "item" )

weapon_bow.data = {
	name  = "Bow",
	image = "images/entities/weapon_bow.png"
}

function weapon_bow:weapon_bow()
	item.item( self )
end

if ( _CLIENT ) then
	function weapon_bow:getOptions()
		return {
			{
				name  = "Pickup",
				value = function() self:pickup() end
			},
			{
				name  = "Examine",
				value = function() self:examine() end
			}
		}
	end
end

function weapon_bow:pickup()
	localplayer:pickup( self )
end

function weapon_bow:examine()
	chat.addText( "It's a bow. What else did you expect?" )
end

function weapon_bow:spawn()
	entity.spawn( self )

	local tileSize = game.tileSize
	local min      = vector()
	local max      = vector( tileSize, -tileSize )
	self:initializePhysics( "dynamic" )
	self:setCollisionBounds( min, max )
end

entities.linkToClassname( weapon_bow, "weapon_bow" )
