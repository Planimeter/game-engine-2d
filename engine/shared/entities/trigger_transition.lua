--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: trigger_transition
--
--============================================================================--

require( "engine.shared.entities.trigger" )

class "trigger_transition" ( "trigger" )

function trigger_transition:trigger_transition()
	trigger.trigger( self )
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
			local players = player.getInOrNearRegion( r )
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
