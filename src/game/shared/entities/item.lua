--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: item
--
--============================================================================--

require( "engine.shared.entities.entity" )

class "item" ( "entity" )

item.data = {
	name  = "Unknown Item",
	image = "images/error.png"
}

function item:item()
	entity.entity( self )

	-- local tileSize = game.tileSize
	-- local min      = vector()
	-- local max      = vector( tileSize, -tileSize )
	-- self:setCollisionBounds( min, max )

	self:setNetworkVar( "name", self.data.name )

	if ( _CLIENT ) then
		local sprite = graphics.newImage( self.data.image )
		self:setSprite( sprite )
	end
end
