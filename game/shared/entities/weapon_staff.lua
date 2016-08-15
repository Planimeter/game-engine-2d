--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: weapon_staff
--
--============================================================================--

require( "game.shared.entities.item" )
require( "game" )

if ( _CLIENT ) then
require( "engine.client.chat" )
end

class "weapon_staff" ( "item" )

weapon_staff.data = {
	name  = "Staff",
	image = "images/entities/weapon_staff.png"
}

function weapon_staff:weapon_staff()
	item.item( self )
end

if ( _CLIENT ) then
	function weapon_staff:getOptions()
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

function weapon_staff:pickup()
	localplayer:pickup( self )
end

function weapon_staff:examine()
	chat.addText( "Brown and sticky." )
end

function weapon_staff:spawn()
	entity.spawn( self )

	local tileSize = game.tileSize
	local min      = vector()
	local max      = vector( tileSize, -tileSize )
	self:initializePhysics( "dynamic" )
	self:setCollisionBounds( min, max )
end

entities.linkToClassname( weapon_staff, "weapon_staff" )
