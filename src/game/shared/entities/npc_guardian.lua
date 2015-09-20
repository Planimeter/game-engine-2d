--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: npc_guardian
--
--============================================================================--

require( "engine.shared.entities.npc" )

class "npc_guardian" ( "npc" )

function npc_guardian:npc_guardian()
	npc.npc( self )
end

entities.linkToClassname( npc_guardian, "npc_guardian" )
