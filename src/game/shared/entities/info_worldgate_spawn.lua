--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: info_worldgate_spawn
--
--============================================================================--

require( "engine.shared.entities.entity" )

class "info_worldgate_spawn" ( "entity" )

function info_worldgate_spawn:info_worldgate_spawn()
	entity.entity( self )
end

entities.linkToClassname( info_worldgate_spawn, "info_worldgate_spawn" )
