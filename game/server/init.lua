--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: Game server interface
--
--==========================================================================--

local _G = _G

module( "game.server" )

function getPlayerClass()
	-- Vertex Adventure's player class is `vaplayer`. In a class-based
	-- multiplayer game, you might want to change this.
	local entities = _G.entities
	entities.require( "vaplayer" )

	-- Return the class
	local classmap = entities.getClassMap()
	return classmap[ "vaplayer" ]
end

function getSpawnPoint( player )
	-- Find the first `prop_worldgate_spawn` in the player's current map
	local map         = player:getMap()
	local entity      = _G.entity
	local spawnPoints = entity.findByClassname( "prop_worldgate_spawn", map )
	return spawnPoints and spawnPoints[ 1 ] or nil
end

function load( arg )
end

function onPlayerConnect( player )
end

function onPlayerSay( player, message )
	return true
end

function onPlayerUse( player, entity, value )
	return true
end

if ( _VADVENTURE ) then
	function onNPCTalkTo( npc, player, dialogue )
		-- Check if the player is too far away
		local pos1     = npc:getPosition()
		local pos2     = player:getPosition()
		local dist     = pos1 - pos2
		local tileSize = _G.game.tileSize
		if ( dist:lengthSqr() > tileSize * tileSize ) then
			player:sendText( "You can't reach that." )
			return false
		end
		return true
	end
end

function onTick( timestep )
end

function quit()
end

shutdown = quit

function update( dt )
end
