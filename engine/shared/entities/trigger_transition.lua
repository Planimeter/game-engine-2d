--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: trigger_transition
--
--==========================================================================--

entities.requireEntity( "trigger" )

class "trigger_transition" ( "trigger" )

function trigger_transition:trigger_transition()
	trigger.trigger( self )
end

function trigger_transition:getDirection()
	local position = self:getPosition()
	local north    = vector( 0, -game.tileSize )
	local width    = self:getNetworkVar( "width" )
	local length   = self:getNetworkVar( "height" )
	if ( region.getAtPosition( position + north ) == nil and
	     width > length ) then
		return "north"
	end

	local east  = vector( width, 0 )
	if ( region.getAtPosition( position + east ) == nil and
	     length > width ) then
		return "east"
	end

	local south  = vector( 0, length )
	if ( region.getAtPosition( position + south ) == nil and
	     width > length ) then
		return "south"
	end

	local west = vector( -game.tileSize, 0 )
	if ( region.getAtPosition( position + west ) == nil and
	     length > width ) then
		return "west"
	end
end

function trigger_transition:findRegionSpace()
	local direction  = self:getDirection()
	if ( direction == nil ) then
		return
	end

	local x, y       = 0, 0
	local position   = self:getPosition()
	local width      = self:getNetworkVar( "width" )
	local length     = self:getNetworkVar( "height" )
	local properties = self:getProperties()
	local offsetx    = properties and properties[ "offsetx" ] or 0
	local offsety    = properties and properties[ "offsety" ] or 0

	if ( direction == "north" ) then
		x = position.x          + offsetx
		y = position.y - length + offsety
		return x, y, direction
	end

	if ( direction == "east" ) then
		x = position.x + width                  + offsetx
		y = position.y - length + game.tileSize + offsety
		return x, y, direction
	end

	if ( direction == "south" ) then
		x = position.x + offsetx
		y = position.y + offsety
		return x, y, direction
	end

	if ( direction == "south" ) then
		x = position.x          + offsetx
		y = position.y - length + offsety
		return x, y, direction
	end
end

function trigger_transition:loadRegion()
	local properties = self:getProperties()
	if ( properties == nil ) then
		return
	end

	local name = properties[ "region" ]
	if ( region.getByName( name ) ) then
		return
	end

	local x, y, direction = self:findRegionSpace()
	if ( direction == nil ) then
		-- Prevent loading regions twice
		return
	end

	-- local currentRegion = self:getRegion()
	-- print( "Loading " .. name .. " " .. direction .. " of " ..
	--        currentRegion:getName() .. " at " .. tostring( vector( x, y ) ) )

	if ( direction == "north" ) then
		-- Find region length
		local regionData = require( "regions." .. name )
		local length     = self:getNetworkVar( "height" )
		local height     = regionData.height * game.tileSize
		y = y - height
	end

	if ( direction == "west" ) then
		-- Find region width
		local regionData = require( "regions." .. name )
		local width      = regionData.width * game.tileSize
		x = x - width
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
			if ( players == nil ) then
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
