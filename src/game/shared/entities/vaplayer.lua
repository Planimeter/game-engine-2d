--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: vaplayer
--
--============================================================================--

require( "engine.shared.entities.player" )

class "vaplayer" ( "player" )

function vaplayer:vaplayer()
	player.player( self )
end

function vaplayer:getInventory()
end

entities.linkToClassname( vaplayer, "vaplayer" )
