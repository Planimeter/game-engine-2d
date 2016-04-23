--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: npc_franz, servant jock
--
--============================================================================--

require( "engine.shared.entities.npc" )

class "npc_franz" ( "npc" )

function npc_franz:npc_franz()
	npc.npc( self )
	self:setNetworkVar( "name", "Franz" )
end

if ( _CLIENT ) then
	function npc_franz:getOptions()
		return {
			{
				name  = "Talk",
				value = function() self:talk() end
			},
			{
				name  = "Examine",
				value = function() self:examine() end
			}
		}
	end
end

function npc_franz:talk()
	dialogue.send()
end

function npc_franz:examine()
	chat.addText( "Servant jock. Seems to be wearing fake muscles..." )
end

entities.linkToClassname( npc_franz, "npc_franz" )
