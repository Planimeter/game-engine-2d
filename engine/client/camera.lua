--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Camera interface
--
--============================================================================--

require( "common.vector" )

module( "camera" )

_contexts = _contexts or {}

class( "context" )

function context:context( worldIndex, x, y, func )
	self.worldIndex = worldIndex
	self.position   = vector( x, y )
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

function context:remove()
	for i, v in ipairs( _contexts ) do
		if ( v == self ) then
			table.remove( _contexts, i )
		end
	end
end

function drawToWorld( worldIndex, x, y, func )
	local context = context( worldIndex, x, y, func )
	table.insert( _contexts, context )
end

_entity = _entity or nil

function getParentEntity()
	return _entity
end

_position = _position or vector()

function getPosition()
	local entity = getParentEntity()
	if ( entity ) then
		return entity:getPosition()
	end

	return _position
end

function getTranslation()
	local pos    = getPosition()
	local width  = love.graphics.getWidth()
	local height = love.graphics.getHeight()
	local scale  = getZoom()
	if ( not pos ) then pos = vector.origin end
	return -pos.x + ( width  / 2 ) / scale,
	       -pos.y + ( height / 2 ) / scale
end

function getWorldContexts()
	return _contexts
end

_worldIndex = _worldIndex or 1

function getWorldIndex()
	local entity = getParentEntity()
	if ( entity ) then
		return entity:getWorldIndex()
	end

	return _worldIndex
end

_minZoom = _minZoom or point( 1 )

function getMinZoom()
	return _minZoom
end

_maxZoom = _maxZoom or point( 4 )

function getMaxZoom()
	return _maxZoom
end

_zoom = _zoom or point( 1 )

function getZoom()
	return _zoom
end

_tween = _tween or nil

function resetZoom()
	if ( not _tween ) then
		_tween = tween( _M, nil, {
			_zoom = point( 2 ),
			onComplete = function()
				_tween = nil
			end
		} )
	end

	_tween.pos = 0
end

function screenToWorld( x, y )
	local pos    = getPosition()
	local width  = love.graphics.getWidth()
	local height = love.graphics.getHeight()
	local scale  = getZoom()
	if ( not pos ) then pos = vector.origin end
	return pos.x - ( width  / 2 ) / scale + x / scale,
	       pos.y - ( height / 2 ) / scale + y / scale
end

function worldToScreen( x, y )
	local pos    = getPosition()
	local width  = love.graphics.getWidth()
	local height = love.graphics.getHeight()
	local scale  = getZoom()
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

function setZoom( zoom )
	if ( _tween ) then
		return
	end

	_zoom = math.clamp( zoom, getMinZoom(), getMaxZoom() )
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
