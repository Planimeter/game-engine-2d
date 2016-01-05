--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
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
end

function trigger_transition:findRegionSpace()
	local pos    = self:getPosition()
	local width  = self:getNetworkVar( "width" )
	local length = self:getNetworkVar( "height" )

	-- Find region space north
	local x = pos.x
	local y = pos.y - game.tileSize - 1
	local r = region.getAtPosition( vector( x, y ) )
	if ( not r ) then
		return x, y, "north"
	end

	-- Find region space east
	x = pos.x + width
	y = pos.y - length
	r = region.getAtPosition( vector( x, y ) )
	if ( not r and length > width ) then
		return x, y, "east"
	end

	-- Find region space south
	x = pos.x
	y = pos.y
	r = region.getAtPosition( vector( x, y ) )
	if ( not r ) then
		return x, y, "south"
	end

	-- Find region space west
	x = pos.x
	y = pos.y
	r = region.getAtPosition( vector( x, y ) )
	if ( not r and length > width ) then
		return x, y, "west"
	end

	return pos.x, pos.y
end

function trigger_transition:getPlayersInOrNearRegion( region )
	local t = {}
	for _, player in ipairs( player.getAll() ) do
		local minA, maxA = player:getViewportBounds()

		local x,  y  = region:getX(), region:getY()
		local width  = region:getPixelWidth()
		local height = region:getPixelHeight()
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

	local x, y, direction = self:findRegionSpace()
	if ( direction == "north" ) then
		-- Find region length
		local regionData = require( "regions." .. name )
		local length     = regionData.height * game.tileSize
		y = y - length + 1
	end

	region.load( name, x, y )
end

function trigger_transition:removeRegion()
	local properties = self:getProperties()
	if ( properties ) then
		local name = properties[ "region" ]
		local r = region.getByName( name )
		if ( r ) then
			local players = self:getPlayersInOrNearRegion( r )
			if ( not players ) then
				region.unload( name )
			end
		end
	end
end

function trigger_transition:update( dt )
	for _, player in ipairs( player.getAll() ) do
		if ( self:isVisibleToPlayer( player ) ) then
			if ( not self.loaded ) then
				self:loadRegion()
				self.loaded = true
			end
		else
			if ( self.loaded ) then
				self:removeRegion()
				self.loaded = false
			end
		end
	end
end

entities.linkToClassname( trigger_transition, "trigger_transition" )
