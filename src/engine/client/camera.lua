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

local width  = 0
local height = 0
local pos    = vector.origin

function getTranslation()
	width  = graphics.getViewportWidth()
	height = graphics.getViewportHeight()
	pos    = getPosition()
	if ( not pos ) then pos = vector.origin end
	return width / 2 - pos.x, height / 2 - pos.y
end

function preWorldDraw()
	graphics.push()
	graphics.translate( getTranslation() )
end

function postWorldDraw()
	graphics.pop()
end

function setPosition( position )
	_position = position
end

local xp, yp = 0, 0

function worldToScreen( x, y )
	xp, yp = getTranslation()
	return xp + x, yp + y
end
