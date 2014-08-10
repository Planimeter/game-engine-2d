--========= Copyright © 2013-2014, Planimeter, All rights reserved. ==========--
--
-- Purpose: info_worldgate_spawn
--
--============================================================================--

require( "engine.shared.entities.player" )

class "vaplayer" ( "player" )

function vaplayer:vaplayer()
	player.player( self )
end

entities.linkToClassname( vaplayer, "vaplayer" )
