--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: trigger_changelevel
--
--==========================================================================--

entities.require( "trigger" )

class "trigger_changelevel" ( "trigger" )

function trigger_changelevel:trigger_changelevel()
	trigger.trigger( self )
end

function trigger_changelevel:loadMap()
	local properties = self:getProperties()
	if ( properties == nil ) then
		return
	end

	local name = properties[ "map" ]
	if ( map.getByName( name ) ) then
		return
	end

	local worldIndex = map.findNextWorldIndex()
	map.load( name, nil, nil, worldIndex )
end

function trigger_changelevel:removeMap()
	local properties = self:getProperties()
	if ( properties ) then
		local name = properties[ "map" ]
		local r = map.getByName( name )
		if ( r ) then
			local players = player.getInOrNearMap( r )
			if ( players == nil ) then
				map.unload( name )
			end
		end
	end
end

function trigger_changelevel:tick( timestep )
	for _, player in ipairs( player.getAll() ) do
		if ( self:isVisibleToPlayer( player ) ) then
			if ( not self.loaded ) then
				self:loadMap()
				self.loaded = true
			end
		else
			if ( self.loaded ) then
				self:removeMap()
				self.loaded = false
			end
		end
	end
end

entities.linkToClassname( trigger_changelevel, "trigger_changelevel" )
