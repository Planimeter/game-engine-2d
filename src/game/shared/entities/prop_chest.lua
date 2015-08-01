--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: prop_chest
--
--============================================================================--

require( "engine.shared.entities.entity" )
require( "game" )

class "prop_chest" ( "entity" )

function prop_chest:prop_chest()
	entity.entity( self )

	local tileSize = game.tileSize
	local min      = vector()
	local max      = vector( tileSize, -tileSize )
	self:setCollisionBounds( min, max )

	self:setNetworkVar( "name", "Chest" )

	if ( _CLIENT ) then
		local sprite = graphics.newImage( "images/entities/prop_chest.png" )
		self:setSprite( sprite )
	end
end

if ( _CLIENT ) then
	-- TODO: Integrate with gui.hudmoveindicator?
	function prop_chest:getOptions()
		return {
			["Open"]    = self.open,
			["Examine"] = self.examine
		}
	end
end

function prop_chest:open()
end

function prop_chest:examine()
end

entities.linkToClassname( prop_chest, "prop_chest" )
