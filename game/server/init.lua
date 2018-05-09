--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: Game server interface
--
--==========================================================================--

local _G = _G

module( "game.server" )

function getPlayerClass()
	_G.entities.requireEntity( "vaplayer" )
	local classmap = _G.entities.getClassMap()
	local vaplayer = classmap[ "vaplayer" ]
	return vaplayer
end

function getSpawnPoint( player )
	local class       = "prop_worldgate_spawn"
	local region      = player:getRegion()
	local spawnPoints = _G.entity.findByClassname( class, region )
	return spawnPoints and spawnPoints[ 1 ] or nil
end

function load( arg )
end

function onPlayerConnect( player )
end

function onPlayerSay( player, message )
	return true
end

function onTick( timestep )
end

function quit()
end

shutdown = quit

function update( dt )
end
