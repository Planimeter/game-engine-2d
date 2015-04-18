--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: prop_torch
--
--============================================================================--

require( "engine.shared.entities.entity" )

class "prop_torch" ( "entity" )

function prop_torch:prop_torch()
	entity.entity( self )

	self:setNetworkVar( "name", "Torch" )

	if ( _CLIENT ) then
		local sprite = graphics.newImage( "images/entities/prop_torch.png" )
		self:setSprite( sprite )
	end
end

if ( _CLIENT ) then
	function prop_torch:getActions()
		return {
			["Examine"] = self.examine
		}
	end
end

function prop_torch:examine()
end

entities.linkToClassname( prop_torch, "prop_torch" )
