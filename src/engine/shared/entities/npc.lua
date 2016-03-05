--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: NPC class
--
--============================================================================--

require( "engine.shared.entities.character" )

class "npc" ( "character" )

function npc:npc()
	character.character( self )

	local tileSize = game.tileSize
	local min      = vector()
	local max      = vector( tileSize, -tileSize )
	self:setCollisionBounds( min, max )

	self:networkNumber( "moveSpeed", 0.5 )

	if ( _CLIENT ) then
		require( "engine.client.sprite" )
		local sprite = sprite( "images.player" )
		self:setSprite( sprite )
	end
end

function npc:spawn()
	entity.spawn( self )
	game.call( "shared", "onNPCSpawn", self )
end

function npc:__tostring()
	return "npc: " .. self:getName()
end
