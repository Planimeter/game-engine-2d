--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: prop_tree
--
--============================================================================--

require( "engine.shared.entities.entity" )

class "prop_tree" ( "entity" )

function prop_tree:prop_tree()
	entity.entity( self )

	self:setNetworkVar( "name", "Tree" )

	if ( _CLIENT ) then
		local sprite = graphics.newImage( "images/entities/prop_tree/1.png" )
		self:setSprite( sprite )
	end
end

if ( _CLIENT ) then
	-- TODO: Integrate with gui.hudmoveindicator?
	function prop_tree:getActions()
		return {
			["Chop Down"] = self.chopDown,
			["Examine"]   = self.examine
		}
	end
end

function prop_tree:chopDown()
end

function prop_tree:examine()
end

entities.linkToClassname( prop_tree, "prop_tree" )
