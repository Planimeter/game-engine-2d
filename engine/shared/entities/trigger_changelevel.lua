--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: trigger_changelevel
--
--============================================================================--

require( "engine.shared.entities.trigger" )

class "trigger_changelevel" ( "trigger" )

function trigger_changelevel:trigger_changelevel()
	trigger.trigger( self )
end

function trigger_changelevel:loadRegion()
	local properties = self:getProperties()
	if ( not properties ) then
		return
	end

	local name = properties[ "region" ]
	if ( region.getByName( name ) ) then
		return
	end

	local worldIndex = region.findNextWorldIndex()
	region.load( name, nil, nil, worldIndex )
end

function trigger_changelevel:removeRegion()
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

function trigger_changelevel:update( dt )
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

entities.linkToClassname( trigger_changelevel, "trigger_changelevel" )
