--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: prop_worldgate_spawn
--
--==========================================================================--

entities.require( "entity" )
require( "game" )

if ( _CLIENT ) then
	require( "engine.client.chat" )
end

class "prop_worldgate_spawn" ( "entity" )

function prop_worldgate_spawn:prop_worldgate_spawn()
	entity.entity( self )

	if ( _CLIENT ) then
		local tileSize = game.tileSize
		self:setLocalPosition( vector( -tileSize, 0 ) )
	end

	self:setNetworkVar( "name", "World Gate" )

	if ( _CLIENT ) then
		local filename = "images/entities/prop_worldgate_spawn.png"
		local sprite   = love.graphics.newImage( filename )
		sprite:setFilter( "nearest", "nearest" )
		self:setSprite( sprite )
	end
end

if ( _CLIENT ) then
	function prop_worldgate_spawn:getOptions()
		return {
			{
				name  = "Examine",
				value = function() self:examine() end
			}
		}
	end

	function prop_worldgate_spawn:examine()
		chat.addText( "Rather tall and ominous." )
	end
end

function prop_worldgate_spawn:spawn()
	entity.spawn( self )

	local tileSize = game.tileSize
	local min      = vector()
	local max      = vector( tileSize, -tileSize )
	self:initializePhysics()
	self:setCollisionBounds( min, max )
end

function prop_worldgate_spawn:update( dt )
	local position = self:getPosition()
	local players  = player.getAll()
	for _, player in ipairs( players ) do
		if ( player:getPosition() == position ) then
			player:moveTo( position + vector( 0, game.tileSize ) )
		end
	end
end

entities.linkToClassname( prop_worldgate_spawn, "prop_worldgate_spawn" )
