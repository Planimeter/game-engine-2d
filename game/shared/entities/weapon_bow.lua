--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: weapon_bow
--
--==========================================================================--

require( "game.shared.entities.item" )
require( "game" )

class "weapon_bow" ( "item" )

weapon_bow.data = {
	name  = "Bow",
	image = "images/entities/weapon_bow.png"
}

function weapon_bow:weapon_bow()
	item.item( self )
end

if ( _CLIENT ) then
	function weapon_bow:pickup()
		localplayer:pickup( self )
	end

	function weapon_bow:drop()
		localplayer:drop( self.__type )
	end

	function weapon_bow:examine()
		chat.addText( "It's a bow. What else did you expect?" )
	end
end

function weapon_bow:spawn()
	entity.spawn( self )

	local tileSize = game.tileSize
	local min      = vector()
	local max      = vector( tileSize, -tileSize )
	self:initializePhysics( "dynamic" )
	self:setCollisionBounds( min, max )

	local body = self:getBody()
	if ( body ) then
		body:setMass( 1.81437 )
	end
end

entities.linkToClassname( weapon_bow, "weapon_bow" )
