--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Camera interface
--
--============================================================================--

require( "common.vector" )

-- These values are preserved during real-time scripting.
local contexts   = camera and camera.getWorldContexts() or {}
local entity     = camera and camera.getParentEntity()
local position   = camera and camera.getPosition() or vector()
local worldIndex = camera and camera.getWorldIndex() or 1
local minZoom    = camera and camera.getMinZoom() or 1
local maxZoom    = camera and camera.getMaxZoom() or 4
local zoom       = camera and camera.getZoom() or 1

local class      = class
local concommand = concommand
local graphics   = graphics
local ipairs     = ipairs
local math       = math
local table      = table
local tween      = tween
local vector     = vector

module( "camera" )

local _contexts = contexts

class( "context" )

function context:context( x, y, func )
	self.position   = vector( x, y )
	-- TODO: Add worldIndex to constructor.
	self.worldIndex = 1
	self._drawFunc  = func
end

function context:draw()
	self._drawFunc()
	self:remove()
end

function context:getDrawPosition()
	local position = self.position
	return position.x, position.y
end

function context:getPosition()
	return self.position
end

function context:getWorldIndex()
	return self.worldIndex
end

function context:isInViewport()
	-- TODO: Implement me.
	return true
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

function getParentEntity()
	return _entity
end

local _position = position

function getPosition()
	local entity = getParentEntity()
	if ( entity ) then
		return entity:getPosition()
	end

	return _position
end

local pos    = vector.origin
local width  = 0
local height = 0
local scale  = 1

function getTranslation()
	pos    = getPosition()
	width  = graphics.getViewportWidth()
	height = graphics.getViewportHeight()
	scale  = getZoom()
	if ( not pos ) then pos = vector.origin end
	return -pos.x + ( width  / 2 ) / scale,
	       -pos.y + ( height / 2 ) / scale
end

function getWorldContexts()
	return _contexts
end

local _worldIndex = worldIndex

function getWorldIndex()
	local entity = getParentEntity()
	if ( entity ) then
		return entity:getWorldIndex()
	end

	return _worldIndex
end

local _minZoom = minZoom

function getMinZoom()
	return _minZoom
end

local _maxZoom = maxZoom

function getMaxZoom()
	return _maxZoom
end

local _private = {
	_zoom = zoom
}

function getZoom()
	return _private._zoom
end

local _tween = nil

function resetZoom()
	if ( not _tween ) then
		_tween = tween( _private, nil, {
			_zoom = 2,
			onComplete = function()
				_tween = nil
			end
		} )
	end

	_tween.pos = 0
end

function screenToWorld( x, y )
	pos    = getPosition()
	width  = graphics.getViewportWidth()
	height = graphics.getViewportHeight()
	scale  = getZoom()
	if ( not pos ) then pos = vector.origin end
	return pos.x - ( width  / 2 ) / scale + x / scale,
	       pos.y - ( height / 2 ) / scale + y / scale
end

function worldToScreen( x, y )
	pos    = getPosition()
	width  = graphics.getViewportWidth()
	height = graphics.getViewportHeight()
	scale  = getZoom()
	if ( not pos ) then pos = vector.origin end
	return pos.x * -scale + ( width  / 2 ) + x * scale,
	       pos.y * -scale + ( height / 2 ) + y * scale
end

function setParentEntity( entity )
	_entity = entity
end

function setPosition( position )
	_position = position
end

function setMinZoom( minZoom )
	_minZoom = minZoom
end

function setMaxZoom( maxZoom )
	_maxZoom = maxZoom
end

local clamp = math.clamp

function setZoom( zoom )
	if ( _tween ) then
		return
	end

	_private._zoom = clamp( zoom, getMinZoom(), getMaxZoom() )
end

concommand( "zoomin", "Zooms the camera in", function()
	local scale = getZoom()
	setZoom( scale * 2 )
end )

concommand( "zoomout", "Zooms the camera out", function()
	local scale = getZoom()
	setZoom( scale / 2 )
end )

function update( dt )
	if ( _tween ) then
		_tween:update( dt )
	end
end
