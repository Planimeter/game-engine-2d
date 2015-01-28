--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Camera interface
--
--============================================================================--

require( "common.vector" )

-- These values are preserved during real-time scripting.
local position = camera and camera.getPosition() or vector()

local graphics = graphics
local vector   = vector

module( "camera" )

local _position = position

function getPosition()
	return _position
end

function preWorldDraw()
	graphics.push()
	local width	   = graphics.getViewportWidth()
	local height   = graphics.getViewportHeight()
	local position = getPosition()
	if ( not position ) then
		position = vector.origin
	end
	graphics.translate( width  / 2 - position.x,
						height / 2 - position.y )
end

function postWorldDraw()
	graphics.pop()
end

function setPosition( position )
	_position = position
end
