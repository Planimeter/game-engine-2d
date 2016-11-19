--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Trigger class
--
--============================================================================--

require( "engine.shared.entities.entity" )

module( "trigger", package.class, package.inherit( "entity" ) )

function trigger:trigger()
	entity.entity( self )

	self:networkNumber( "width",  0 )
	self:networkNumber( "height", 0 )
end

function trigger:isVisibleToPlayer( player )
	local minA, maxA = player:getViewportBounds()
	local width      = self:getNetworkVar( "width" )
	local height     = self:getNetworkVar( "height" )
	local minB       = self:localToWorld( vector() )
	local maxB       = self:localToWorld( vector( width, -height ) )
	return math.aabbsintersect( minA, maxA, minB, maxB )
end
