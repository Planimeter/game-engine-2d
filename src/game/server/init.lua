--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Game server interface
--
--============================================================================--

local unrequire = unrequire
local _G		= _G

module( "game.server" )

function getSpawnPoint( player )
	local class		  = "info_worldgate_spawn"
	local region	  = player:getRegion()
	local spawnPoints = _G.entity.findByClassname( class, region )
	if ( spawnPoints ) then
		return spawnPoints[ 1 ]
	else
		return nil
	end
end

function load( arg )
end

function onPlayerConnect( player )
end

function quit()
	unrequire( "game.server" )
	_G.gameserver = nil
end

shutdown = quit

function update( dt )
end
