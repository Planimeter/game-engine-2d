--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: trigger_transition
--
--============================================================================--

require( "engine.shared.entities.entity" )

class "trigger_transition" ( "entity" )

function trigger_transition:trigger_transition()
	entity.entity( self )

	self:networkNumber( "width",  0 )
	self:networkNumber( "height", 0 )

	self.color = color.red
end

function trigger_transition:draw()
	local width  = self:getNetworkVar( "width" )
	local height = self:getNetworkVar( "height" )
	graphics.setColor( self.color )
	graphics.rectangle( "line", 0, 0, width, height )
end

function trigger_transition:getPlayersNearRegion( region )
	local t = {}
	for _, player in ipairs( player.getAll() ) do
		local minA, maxA = player:getViewportBounds()

		local x,  y  = region:getX(), region:getY()
		local width  = region:getWidth()  * region:getTileWidth()
		local height = region:getHeight() * region:getTileHeight()
		local minB   = vector( x, y + height )
		local maxB   = vector( x + width, y )

		if ( math.aabbsintersect( minA, maxA, minB, maxB ) ) then
			table.insert( t, player )
		end
	end
	return #t > 0 and t or nil
end

function trigger_transition:isVisibleToPlayer( player )
	local minA, maxA = player:getViewportBounds()
	local width      = self:getNetworkVar( "width" )
	local height     = self:getNetworkVar( "height" )
	local minB       = self:localToWorld( vector() )
	local maxB       = self:localToWorld( vector( width, -height ) )
	return math.aabbsintersect( minA, maxA, minB, maxB )
end

function trigger_transition:loadRegion()
	local properties = self:getProperties()
	if ( not properties ) then
		return
	end

	local name = properties[ "region" ]
	if ( region.getByName( name ) ) then
		return
	end

	local pos = self:getPosition()
	region.load( name, pos.x, pos.y )
end

function trigger_transition:removeRegion()
	local r = region.getAtPosition( self:getPosition() )
	if ( r ) then
		local players = self:getPlayersNearRegion( r )
		local name    = r:getName()
		if ( not players ) then
			region.unload( name )
		end
	end

	local properties = self:getProperties()
	if ( properties ) then
		local name = properties[ "region" ]
		local r = region.getByName( name )
		if ( r ) then
			local players = self:getPlayersNearRegion( r )
			if ( not players ) then
				region.unload( name )
			end
		end
	end
end

function trigger_transition:update( dt )
	for _, player in ipairs( player.getAll() ) do
		if ( self:isVisibleToPlayer( player ) ) then
			self.color = color( 0, 255, 0, 255 )
			self:loadRegion()
		else
			self.color = color.red
			self:removeRegion()
		end
	end
end

entities.linkToClassname( trigger_transition, "trigger_transition" )
