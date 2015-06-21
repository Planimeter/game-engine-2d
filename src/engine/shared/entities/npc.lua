--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: NPC class
--
--============================================================================--

require( "engine.shared.entities" )
require( "engine.shared.entities.entity" )

class "npc" ( "entity" )

function npc:npc()
	entity.entity( self )

	local tileSize = game.tileSize
	if ( _CLIENT ) then
		self:setLocalPosition( vector( 0, tileSize ) )
	end

	local min = vector()
	local max = vector( tileSize, -tileSize )
	self:setCollisionBounds( min, max )

	self:networkNumber( "moveSpeed", 2 )

	if ( _CLIENT ) then
		self:setSprite( player.sprite )
	end
end

function npc:move()
	-- Get direction to move
	local start     = self:getPosition()
	local next      = self.path[ 1 ]
	local direction = ( next - start )
	direction:normalizeInPlace()

	-- Apply move speed to directional vector
	direction = direction * self:getNetworkVar( "moveSpeed" )

	-- Snap to pixel grid
	direction.x = math.round( direction.x )
	direction.y = math.round( direction.y )

	-- Where we'll move to
	local newPosition = start + direction

	-- Ensure we're not passing the next tile by comparing the
	-- distance traveled to the distance to the next tile
	if ( direction:length() >= ( next - start ):length() ) then
		newPosition = next
		table.remove( self.path, 1 )
	end

	-- Move
	self:setNetworkVar( "position", newPosition )

	-- We've reached our goal
	if ( #self.path == 0 ) then
		self.path = nil
	end
end

function npc:moveTo( position )
	if ( position == self:getPosition() ) then
		return
	end

	if ( _SERVER ) then
		require( "engine.shared.path" )
		self.nextPath = path.getPath( self:getPosition(), position )
	end
end

function npc:spawn()
	entity.spawn( self )
	game.call( "shared", "onNPCSpawn", self )
end

function npc:__tostring()
	return "npc: " .. self:getName()
end
