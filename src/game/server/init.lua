--========= Copyright © 2013-2014, Planimeter, All rights reserved. ==========--
--
-- Purpose: Game server interface
--
--============================================================================--

require( "engine.shared.entities" )

local entities	= entities
local ipairs	= ipairs
local print		= print
local table		= table
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

function initializeEntities( regionEntities )
	local t = {}
	for i, entityData in ipairs( regionEntities ) do
		local entity = entities.createFromRegionData( entityData )
		if ( entity ) then
			entity:spawn()
			table.insert( t, entity )
		end
	end
	return t
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
