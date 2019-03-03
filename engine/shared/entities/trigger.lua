--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Trigger class
--
--==========================================================================--

entities.require( "entity" )

class "trigger" ( "entity" )

function trigger:trigger()
	entity.entity( self )

	self:networkNumber( "width",  0 )
	self:networkNumber( "height", 0 )
end

function trigger:isVisibleToPlayer( player )
	local minA, maxA = player:getGraphicsBounds()
	local width      = self:getNetworkVar( "width" )
	local height     = self:getNetworkVar( "height" )
	local minB       = self:localToWorld( vector() )
	local maxB       = self:localToWorld( vector( width, -height ) )
	return math.aabbsintersect( minA, maxA, minB, maxB )
end
