--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Game server interface
--
--============================================================================--

local unrequire = unrequire
local _G        = _G

module( "game.server" )

function getSpawnPoint( player )
	local class       = "prop_worldgate_spawn"
	local region      = player:getRegion()
	local spawnPoints = _G.entity.findByClassname( class, region )
	return spawnPoints and spawnPoints[ 1 ] or nil
end

function load( arg )
end

function onPlayerAuthenticated( player )
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
