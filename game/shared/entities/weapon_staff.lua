--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: weapon_staff
--
--==========================================================================--

require( "game.shared.entities.item" )
require( "game" )

class "weapon_staff" ( "item" )

weapon_staff.data = {
	name  = "Staff",
	image = "images/entities/weapon_staff.png"
}

function weapon_staff:weapon_staff()
	item.item( self )
end

if ( _CLIENT ) then
	function weapon_staff:pickup()
		localplayer:pickup( self )
	end

	function weapon_staff:drop()
		localplayer:drop( self.__type )
	end

	function weapon_staff:examine()
		chat.addText( "Brown and sticky." )
	end
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
