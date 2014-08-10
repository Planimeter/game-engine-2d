--========= Copyright © 2013-2014, Planimeter, All rights reserved. ==========--
--
-- Purpose: Camera interface
--
--============================================================================--

require( "common.vector" )

-- These values are preserved during real-time scripting.
local position = camera and camera.getPosition() or vector()

local graphics = graphics

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
	graphics.translate( position.x + width	/ 2,
						position.y + height / 2 )
end

function postWorldDraw()
	graphics.pop()
end

function setPosition( position )
	_position = position
end
