--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: env_soundscape
--
--============================================================================--

require( "engine.shared.entities.entity" )

class "env_soundscape" ( "entity" )

function env_soundscape:env_soundscape()
	entity.entity( self )
end

entities.linkToClassname( env_soundscape, "env_soundscape" )
