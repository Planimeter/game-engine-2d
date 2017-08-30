--=========== Copyright © 2017, Planimeter, All rights reserved. ===========--
--
-- Purpose: prop_chest
--
--==========================================================================--

entities.requireEntity( "entity" )
require( "game" )

class "prop_chest" ( "entity" )

function prop_chest:prop_chest()
	entity.entity( self )

	self:setNetworkVar( "name", "Chest" )

	if ( _CLIENT ) then
		local sprite = love.graphics.newImage( "images/entities/prop_chest.png" )
		self:setSprite( sprite )
	end
end

if ( _CLIENT ) then
	function prop_chest:getOptions()
		return {
			{
				name  = "Open",
				value = function() self:open() end
			},
			{
				name  = "Examine",
				value = self.examine
			}
		}
	end
end

function prop_chest:open()
	if ( _CLIENT ) then
		localplayer:moveTo( self:getPosition() + vector( 0, game.tileSize ) )
	end
end

function prop_chest:examine()
end

function prop_chest:spawn()
	entity.spawn( self )

	local tileSize = game.tileSize
	local min      = vector()
	local max      = vector( tileSize, -tileSize )
	self:initializePhysics()
	self:setCollisionBounds( min, max )
end

entities.linkToClassname( prop_chest, "prop_chest" )
