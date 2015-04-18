--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Camera interface
--
--============================================================================--

require( "common.vector" )

-- These values are preserved during real-time scripting.
local contexts = camera and camera.getWorldContexts() or {}
local entity   = camera and camera.getEntity()
local position = camera and camera.getPosition() or vector()

local class    = class
local graphics = graphics
local ipairs   = ipairs
local table    = table
local vector   = vector

module( "camera" )

local _contexts = contexts

class( "context" )

function context:context( x, y, func )
	self.position  = vector( x, y )
	self._drawFunc = func
end

function context:getPosition()
	return self.position
end

function context:draw()
	self._drawFunc()
	self:remove()
end

function context:remove()
	for i, v in ipairs( _contexts ) do
		if ( v == self ) then
			table.remove( _contexts, i )
		end
	end
end

function drawToWorld( x, y, func )
	local context = context( x, y, func )
	table.insert( _contexts, context )
end

local _entity = entity

function setParentEntity( entity )
	_entity = entity
end

function getParentEntity()
	return _entity
end

local _position = position

function getPosition()
	local entity = getParentEntity()
	if ( entity ) then
		return entity:getNetworkVar( "position" )
	end

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

function getWorldContexts()
	return _contexts
end

function setPosition( position )
	_position = position
end

local xp, yp = 0, 0

function screenToWorld( x, y )
	width  = graphics.getViewportWidth()
	height = graphics.getViewportHeight()
	pos    = getPosition()
	if ( not pos ) then pos = vector.origin end
	xp, yp = pos.x - width / 2, pos.y - height / 2
	return xp + x, yp + y
end

function worldToScreen( x, y )
	xp, yp = getTranslation()
	return xp + x, yp + y
end
