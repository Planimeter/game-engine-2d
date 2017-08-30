--=========== Copyright © 2017, Planimeter, All rights reserved. ===========--
--
-- Purpose: NPC class
--
--==========================================================================--

entities.requireEntity( "character" )

class "npc" ( "character" )

function npc:npc()
	character.character( self )

	self:networkNumber( "moveSpeed", 1 )

	if ( _CLIENT ) then
		require( "engine.client.sprite" )
		local sprite = sprite( "images.player" )
		self:setSprite( sprite )
	end
end

function npc:spawn()
	entity.spawn( self )

	local tileSize = game.tileSize
	local min      = vector()
	local max      = vector( tileSize, -tileSize )
	self:initializePhysics( "dynamic" )
	self:setCollisionBounds( min, max )

	game.call( "shared", "onNPCSpawn", self )
end

function npc:__tostring()
	return "npc: " .. self:getName()
end
