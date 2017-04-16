--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: item
--
--============================================================================--

require( "engine.shared.entities.entity" )

class "item" ( "entity" )

function item.getData( classname )
	entities.requireEntity( classname )
	local classmap = entities.getClassMap()
	return classmap[ classname ].data
end

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
		local sprite = love.graphics.newImage( self.data.image )
		self:setSprite( sprite )
	end
end
