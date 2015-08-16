--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: prop_worldgate_spawn
--
--============================================================================--

require( "engine.shared.entities.entity" )
require( "game" )
require( "engine.client.chat" )

class "prop_worldgate_spawn" ( "entity" )

function prop_worldgate_spawn:prop_worldgate_spawn()
	entity.entity( self )

	local tileSize = game.tileSize
	local min      = vector()
	local max      = vector( tileSize, -tileSize )
	self:setCollisionBounds( min, max )

	if ( _CLIENT ) then
		self:setLocalPosition( vector( -tileSize, 0 ) )
	end

	self:setNetworkVar( "name", "World Gate" )

	if ( _CLIENT ) then
		local sprite = graphics.newImage( "images/entities/prop_worldgate_spawn.png" )
		self:setSprite( sprite )
	end
end

if ( _CLIENT ) then
	function prop_worldgate_spawn:getOptions()
		return {
			{
				name  = "Examine",
				value = self.examine
			}
		}
	end
end

function prop_worldgate_spawn:examine()
	chat.addText( "Rather tall and ominous." )
end

entities.linkToClassname( prop_worldgate_spawn, "prop_worldgate_spawn" )
