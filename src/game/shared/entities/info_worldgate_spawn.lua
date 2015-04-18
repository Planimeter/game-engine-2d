--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: info_worldgate_spawn
--
--============================================================================--

require( "engine.shared.entities.entity" )

class "info_worldgate_spawn" ( "entity" )

function info_worldgate_spawn:info_worldgate_spawn()
	entity.entity( self )

	local tileSize = game.tileSize
	local min      = vector()
	local max      = vector( tileSize, -tileSize )
	self:setCollisionBounds( min, max )
end

function info_worldgate_spawn:draw()
end

entities.linkToClassname( info_worldgate_spawn, "info_worldgate_spawn" )
