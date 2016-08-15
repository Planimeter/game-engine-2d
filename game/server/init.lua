--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Game server interface
--
--============================================================================--

local require   = require
local unrequire = unrequire
local _G        = _G

module( "game.server" )

function getPlayerClass()
	require( "game.shared.entities.vaplayer" )
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

function quit()
	unrequire( "game.server" )
	_G.gameserver = nil
end

shutdown = quit

function update( dt )
end
