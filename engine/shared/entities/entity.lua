--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: Entity class
--
--==========================================================================--

require( "common.vector" )
require( "engine.shared.entities.networkvar" )

class( "entity" )

entity._entities     = entity._entities     or {}
entity._lastEntIndex = entity._lastEntIndex or 0

if ( _CLIENT ) then
	entity._shadowFramebuffer = entity._shadowFramebuffer or nil
end

function entity.create( classname )
	entities.require( classname )

	local classmap = entities.getClassMap()
	if ( classmap[ classname ] == nil ) then
		print( "Attempted to create unknown entity type " .. classname .. "!" )
		return
	end

	local entity = classmap[ classname ]()
	return entity
end

if ( _CLIENT ) then
	local renderables = {}
	local clear       = table.clear
	local append      = table.append

	local shallowcopy = function( from, to )
		for k, v in pairs( from ) do
			to[ k ] = v
		end
	end

	local depthSort = function( t )
		table.sort( t, function( a, b )
			local ay = a:getPosition().y
			local al = a.getLocalPosition and a:getLocalPosition()
			if ( al ) then
				ay = ay + al.y
			end

			local by = b:getPosition().y
			local bl = b.getLocalPosition and b:getLocalPosition()
			if ( bl ) then
				by = by + bl.y
			end
			return ay < by
		end )
	end

	local r_draw_bounding_boxes = convar( "r_draw_bounding_boxes", "0", nil,
	                                      nil, "Draws entity bounding boxes" )

	local r_draw_shadows        = convar( "r_draw_shadows", "1", nil, nil,
	                                      "Draws entity shadows" )

	local r_draw_entities       = convar( "r_draw_entities", "1", nil, nil,
	                                      "Draws entities" )

	local function drawFixture( i, fixture )
		love.graphics.setColor( color( color.white, 0.14 * 255 ) )
		love.graphics.setLineStyle( "rough" )
		local lineWidth = 1
		love.graphics.setLineWidth( lineWidth )
		local topLeftX,
			  topLeftY,
			  bottomRightX,
			  bottomRightY =
			  fixture:getBoundingBox( i )
		local width  = bottomRightX - topLeftX
		local height = bottomRightY - topLeftY
		love.graphics.rectangle(
			"line",
			topLeftX + lineWidth / 2,
			topLeftY + lineWidth / 2,
			width    - lineWidth,
			height   - lineWidth
		)
	end

	local function drawBoundingBox( renderable )
		local worldIndex = camera.getWorldIndex()
		if ( worldIndex ~= renderable:getWorldIndex() ) then
			return
		end

		local isEntity = typeof( renderable, "entity" )
		if ( not isEntity ) then
			return
		end

		local body = renderable:getBody()
		if ( body == nil ) then
			return
		end

		local fixtures = body:getFixtures()
		for i, fixture in ipairs( fixtures ) do
			drawFixture( i, fixture )
		end
	end

	local function drawShadow( renderable )
		local worldIndex = camera.getWorldIndex()
		if ( worldIndex ~= renderable:getWorldIndex() ) then
			return
		end

		local isEntity  = typeof( renderable, "entity" )
		local isTrigger = typeof( renderable, "trigger" )
		if ( not isEntity or isTrigger ) then
			return
		end

		love.graphics.push()
			local x, y   = renderable:getDrawPosition()
			local sprite = renderable:getSprite()
			local height = sprite:getHeight()
			love.graphics.translate( x, y )
			love.graphics.setColor( color.black )
			love.graphics.translate( sprite:getWidth() / 2, height )
			love.graphics.scale( 1, -1 )
			renderable:drawShadow()
		love.graphics.pop()
	end

	local function drawEntity( renderable )
		local worldIndex = camera.getWorldIndex()
		if ( worldIndex ~= renderable:getWorldIndex() ) then
			return
		end

		local isTrigger = typeof( renderable, "trigger" )
		if ( isTrigger ) then
			return
		end

		love.graphics.push()
			local x, y = renderable:getDrawPosition()
			love.graphics.translate( x, y )
			love.graphics.setColor( color.white )
			renderable:draw()
		love.graphics.pop()
	end

	function entity.drawAll()
		clear( renderables )
		shallowcopy( entity._entities, renderables )
		append( renderables, camera.getWorldContexts() )
		depthSort( renderables )

		-- Draw bounding boxes
		if ( r_draw_bounding_boxes:getBoolean() ) then
			for _, v in ipairs( renderables ) do
				drawBoundingBox( v )
			end
		end

		-- Draw shadows
		if ( r_draw_shadows:getBoolean() ) then
			if ( entity._shadowFramebuffer == nil ) then
				require( "engine.client.canvas" )
				entity._shadowFramebuffer = love.graphics.newCanvas()
				entity._shadowFramebuffer:setFilter( "nearest", "nearest" )
			end

			love.graphics.push()
				local canvas = love.graphics.getCanvas()
				love.graphics.setCanvas( entity._shadowFramebuffer )
				love.graphics.clear()
				love.graphics.origin()
				local x, y = camera.screenToWorld( 0, 0 )
				love.graphics.translate( -x, -y )
				for _, v in ipairs( renderables ) do
					drawShadow( v )
				end
				love.graphics.setCanvas( canvas )
			love.graphics.pop()

			love.graphics.push()
				local x, y = camera.screenToWorld( 0, 0 )
				love.graphics.translate( x, y )
				love.graphics.setColor( color( color.white, 0.14 * 255 ) )
				love.graphics.draw( entity._shadowFramebuffer )
			love.graphics.pop()
		end

		-- Draw entities
		if ( r_draw_entities:getBoolean() ) then
			for _, v in ipairs( renderables ) do
				drawEntity( v )
			end
		end
	end
end

local function findByClassnameInMap( classname, map, t )
	local entities = map:getEntities()
	if ( entities == nil ) then
		return
	end

	for i, entity in ipairs( entities ) do
		if ( classname == entity:getClassname() ) then
			table.insert( t, entity )
		end
	end
	return #t > 0 and t or nil
end

local function findByClassname( classname )
	local t = {}
	for i, map in ipairs( map.getAll() ) do
		findByClassnameInMap( classname, map, t )
	end
	return #t > 0 and t or nil
end

function entity.findByClassname( classname, map )
	if ( map ) then
		local t = {}
		return findByClassnameInMap( classname, map, t )
	else
		return findByClassname( classname )
	end
end

function entity.getAll()
	return table.shallowcopy( entity._entities )
end

function entity.getByEntIndex( entIndex )
	for _, v in pairs( entity._entities ) do
		if ( v.entIndex == entIndex ) then
			return v
		end
	end
end

function entity.removeAll()
	while ( #entity._entities > 0 ) do
		entity._entities[ 1 ]:remove()
	end
end

function entity:entity()
	self.entIndex = entity._lastEntIndex + 1

	if ( _SERVER ) then
		entity._lastEntIndex = self.entIndex
	end

	self:networkString( "name",       nil )
	self:networkVector( "position",   vector() )
	self:networkNumber( "worldIndex", 1 )
	self:networkString( "animation",  nil )

	table.insert( entity._entities, self )
end

accessor( entity, "body" )

if ( _CLIENT ) then
	local function drawPosition( self )
		love.graphics.push()
			-- Transformations
			local localPosition = self:getLocalPosition()
			if ( localPosition ) then
				local dx, dy = localPosition.x, localPosition.y
				love.graphics.translate( -dx, -dy )
			end

			love.graphics.scale( 1 / camera.getZoom() )

			-- Set color
			local color = color( color.white, 0.14 * 255 )
			love.graphics.setColor( color )

			-- Set font
			local font = scheme.getProperty( "Default", "fontSmall" )
			love.graphics.setFont( font )

			-- Print text
			local position = tostring( self:getPosition() )
			position       = string.gsub( position, "vector", "position" )
			local velocity = nil
			local body     = self:getBody()
			if ( body and not body:isDestroyed() ) then
				velocity = tostring( vector( body:getLinearVelocity() ) )
				velocity = string.gsub( velocity, "vector", "velocity" )
			end
			local sprite   = self:getSprite()
			local height   = sprite:getHeight()
			local y        = ( height + 1 ) * camera.getZoom()
			love.graphics.print( position, 0, y )
			if ( velocity ) then
				love.graphics.print( velocity, 0, y + font:getHeight() )
			end
		love.graphics.pop()
	end

	function entity:draw()
		local sprite = self:getSprite()
		if ( type( sprite ) == "sprite" ) then
			sprite:draw()
		else
			love.graphics.draw( sprite )
		end

		if ( convar.getConvar( "r_draw_position" ):getBoolean() ) then
			drawPosition( self )
		end
	end

	accessor( entity, "drawShadow", "should", "_drawShadow" )

	function entity:drawShadow()
		if ( self:shouldDrawShadow() == false ) then
			return
		end

		local sprite = self:getSprite()
		local x      = 0
		local y      = 0
		local r      = math.rad( 0 )
		local sx     = 1
		local sy     = 1
		local ox     = sprite:getWidth() / 2
		local oy     = sprite:getHeight()
		local kx     = -1
		local ky     = 0
		if ( type( sprite ) == "sprite" ) then
			love.graphics.draw(
				sprite:getSpriteSheet(),
				sprite:getQuad(),
				x, y, r, sx, sy, ox, oy, kx, ky
			)
		else
			love.graphics.draw(
				sprite,
				x, y, r, sx, sy, ox, oy, kx, ky
			)
		end
	end
end

if ( _CLIENT ) then
	function entity:getAnimation()
		local sprite = self:getSprite()
		if ( type( sprite ) ~= "sprite" ) then
			return
		end

		return sprite:getAnimationName()
	end
end

accessor( entity, "classname", nil, "__type" )

function entity:getCollisionBounds()
	return self._boundsMin, self._boundsMax
end

if ( _CLIENT ) then
	function entity:getDrawPosition()
		local position = self:getPosition()
		local x = position.x
		local y = position.y

		local sprite = self:getSprite()
		local height = sprite:getHeight()
		y = y - height

		local localPosition = self:getLocalPosition()
		if ( localPosition ) then
			x = x + localPosition.x
			y = y + localPosition.y
		end

		return x, y
	end

	accessor( entity, "localPosition" )
end

function entity:getName()
	return self:getNetworkVar( "name" )
end

function entity:getPosition()
	local body = self:getBody()
	if ( body and not body:isDestroyed() ) then
		return vector( body:getPosition() )
	end
	return self:getNetworkVar( "position" )
end

accessor( entity, "predicted", "is" )
accessor( entity, "properties" )
accessor( entity, "map" )

if ( _CLIENT ) then
	accessor( entity, "sprite" )
end

function entity:getWorldIndex()
	return self:getNetworkVar( "worldIndex" )
end

function entity:initializePhysics( type )
	local world    = map.getWorld()
	local position = self:getPosition()
	local x        = position.x
	local y        = position.y
	self.body      = love.physics.newBody( world, x, y, type )
	self.body:setUserData( self )
	self.body:setFixedRotation( true )
	self.body:setLinearDamping( 16 )
	return self.body
end

function entity:isMoving()
	local body = self:getBody()
	if ( body == nil ) then
		return
	end

	return ( vector( body:getLinearVelocity() ) ):lengthSqr() ~= 0
end

function entity:isOnTile()
	local position = self:getPosition()
	return vector( map.snapToGrid( position.x, position.y ) ) == position
end

if ( _CLIENT ) then
	function entity:emitSound( filename )
		require( "engine.client.source" )
		local source = source( filename )
		source:play()
	end
end

function entity:networkVar( name, initialValue )
	self._networkVars = self._networkVars or {}

	local networkvar = networkvar( self, name )
	networkvar:setValue( initialValue )
	self._networkVars[ name ] = networkvar
end

-- Generate the entity:networkType() methods
do
	local networkableTypes = {
		"boolean",
		"number",
		"string",
		"vector"
	}

	for _, type in ipairs( networkableTypes ) do
		entity[ "network" .. string.capitalize( type ) ] =
		function( self, name, initialValue )
			local mt   = getmetatable( self )
			local keys = rawget( mt, "networkVarKeys" ) or {}
			rawset( mt, "networkVarKeys", keys )

			local keyExists = false
			for i, key in ipairs( keys ) do
				if ( key.name == name ) then
					keyExists = true
					break
				end
			end

			if ( not keyExists ) then
				table.insert( keys, {
					name = name,
					type = type
				} )
			end

			self:networkVar( name, initialValue )
		end
	end
end

function entity:setNetworkVar( name, value )
	if ( self._networkVars == nil or not self:hasNetworkVar( name ) ) then
		error( "attempt to set nonexistent networkvar '" .. name .. "'", 2 )
	end

	self._networkVars[ name ]:setValue( value )
end

function entity:getNetworkVar( name )
	if ( not self:hasNetworkVar( name ) ) then
		return nil
	end

	return self._networkVars[ name ]:getValue()
end

function entity:hasNetworkVar( name )
	return self._networkVars[ name ] and true or false
end

function entity:getNetworkVarsStruct()
	local class = getmetatable( self )
	local keys  = rawget( class, "networkVarKeys" ) or {}
	if ( self._networkVarsStruct == nil or
	    #self._networkVarsStruct.keys ~= #keys ) then
		local struct = {
			keys = {}
		}
		for i, key in ipairs( keys ) do
			table.insert( struct.keys, key )
		end
		self._networkVarsStruct = struct
	end
	return self._networkVarsStruct
end

function entity:getNetworkVarTypeLenValues()
	local struct      = self:getNetworkVarsStruct()
	local networkVars = typelenvalues( nil, struct )
	for k, v in pairs( self._networkVars ) do
		networkVars:set( k, v:getValue() )
	end
	return networkVars
end

local cl_interpolate = convar( "cl_interpolate", "1", nil, nil,
                               "Perform client-side interpolation" )

local cl_predict = convar( "cl_predict", "1", nil, nil,
                           "Perform client-side prediction" )

function entity:onNetworkVarChanged( networkvar )
	if ( networkvar:getName() == "position" ) then
		if ( _CLIENT and not _SERVER and cl_interpolate:getBoolean() ) then
			self._lastPosition = {
				value = vector.copy( networkvar:getValue() ),
				time = love.timer.getTime()
			}
		else
			if ( _CLIENT and not _SERVER ) then
				if ( self._lastPosition ) then
					self._lastPosition = nil
				end

				if ( self._interpolationBuffer ) then
					self._interpolationBuffer = nil
				end
			end

			local body = self:getBody()
			if ( body ) then
				local position = networkvar:getValue()
				body:setPosition( position.x, position.y )
			end
		end
	end

	if ( _CLIENT and networkvar:getName() == "animation" ) then
		self:setAnimation( networkvar:getValue() )
	end

	if ( _SERVER ) then
		local payload = payload( "networkVarChanged" )
		payload:set( "entity", self )

		local struct = self:getNetworkVarsStruct()
		local networkVar = typelenvalues( nil, struct )
		networkVar:set( networkvar:getName(), networkvar:getValue() )
		payload:set( "networkVars", networkVar )

		payload:broadcast()
	end
end

function entity:localToWorld( v )
	return self:getPosition() + v
end

if ( _CLIENT ) then
	function entity:onAnimationEnd( animation )
	end

	function entity:onAnimationEvent( event )
	end
end

function entity:onTick( timestep )
	if ( _SERVER ) then
		return
	end

	local lastPosition = self._lastPosition
	if ( lastPosition == nil ) then
		return
	end

	if ( self._interpolationBuffer == nil ) then
		self._interpolationBuffer = {}
	end

	table.insert( self._interpolationBuffer, lastPosition )
	self._lastPosition = nil
end

function entity:remove()
	for i, v in pairs( entity._entities ) do
		if ( v == self ) then
			local body = self:getBody()
			if ( body and not body:isDestroyed() ) then
				body:destroy()
			end
			self.body = nil

			local map = self:getMap()
			map:removeEntity( self )

			table.remove( entity._entities, i )
		end
	end

	if ( _SERVER ) then
		local payload = payload( "entityRemoved" )
		payload:set( "entity", self )
		payload:broadcast()
	end
end

if ( _CLIENT ) then
	local function onEntityRemoved( payload )
		local entity = payload:get( "entity" )
		if ( entity ) then
			entity:remove()
		end
	end

	payload.setHandler( onEntityRemoved, "entityRemoved" )
end

function entity:setAnimation( animation )
	if ( _CLIENT ) then
		local sprite = self:getSprite()
		if ( type( sprite ) ~= "sprite" ) then
			return
		end

		sprite:setAnimation( animation )
	end

	if ( _SERVER ) then
		self:setNetworkVar( "animation", animation )
	end
end

function entity:setCollisionBounds( min, max )
	self._boundsMin = min
	self._boundsMax = max

	local body = self:getBody()
	if ( body == nil ) then
		return
	end

	local fixtures = body:getFixtures()
	local fixture  = fixtures[ 1 ]
	if ( fixture ) then
		fixture:destroy()
	end

	-- BUGBUG: We use magic numbers here to shrink the bounding box of the
	-- fixture.
	local dimensions = max - min
	dimensions.y     = -dimensions.y
	local width      =  dimensions.x - 0.6
	local height     =  dimensions.y - 0.6
	local x          =   width / 2   + 0.3
	local y          = -height / 2   - 0.3
	local shape      = love.physics.newRectangleShape( x, y, width, height )
	local fixture    = love.physics.newFixture( body, shape )
	fixture:setFilterData( 1 --[[ COLLISION_GROUP_NONE ]], 0, 0 )
end

if ( _CLIENT ) then
	function entity:setLocalPosition( position )
		self.localPosition = position
	end
end

function entity:setName( name )
	self:setNetworkVar( "name", name )
end

function entity:setPosition( position )
	self:setNetworkVar( "position", position )
end

function entity:setMap( map )
	local currentMap = self:getMap()
	if ( currentMap ) then
		local entities = currentMap:getEntities()
		for i, v in ipairs( entities ) do
			if ( v == self ) then
				table.remove( entities, i )
			end
		end
	end

	if ( map == nil ) then
		return
	end

	map.entities = map.entities or {}
	if ( table.hasvalue( map.entities, self ) ) then
		return
	end

	table.insert( map.entities, self )
	self.map = map
end

if ( _CLIENT ) then
	function entity:setSprite( sprite )
		if ( type( sprite ) == "sprite" ) then
			sprite.onAnimationEnd = function( _, animation )
				self:onAnimationEnd( animation )
			end

			sprite.onAnimationEvent = function( _, event )
				self:onAnimationEvent( event )
			end
		end

		self.sprite = sprite
	end
end

function entity:spawn()
	local map = self:getMap()
	if ( map == nil ) then
		local position = self:getPosition()
		map = _G.map.getAtPosition( position )
		self:setMap( map )
	end

	if ( _SERVER ) then
		-- TODO: Send entityCreated payload only to players who can see me.
		local payload = payload( "entitySpawned" )
		payload:set( "classname", self:getClassname() )
		payload:set( "entIndex", self.entIndex )
		payload:set( "networkVars", self:getNetworkVarTypeLenValues() )
		payload:broadcast()
	end
end

function entity:testPoint( x, y )
	local body = self:getBody()
	if ( body and not body:isDestroyed() ) then
		local fixtures = body:getFixtures()
		for _, fixture in ipairs( fixtures ) do
			local shape = fixture:getShape()
			if ( shape:testPoint( 0, 0, 0, x, y ) ) then
				return true
			end
		end
	end

	local min, max = self:getCollisionBounds()
	if ( min and max ) then
		local px     = x
		local py     = y
		local pos    = self:getPosition()
		min          = pos + min
		max          = pos + max
		x            = min.x
		y            = max.y
		local width  = max.x - min.x
		local height = min.y - max.y
		if ( map.pointinrect( px, py, x, y, width, height ) ) then
			return true
		end
	end

	return false
end

function entity:updateNetworkVars( payload )
	local struct      = self:getNetworkVarsStruct()
	local networkVars = payload:get( "networkVars" )
	networkVars:setStruct( struct )
	networkVars:deserialize()
	for k, v in pairs( networkVars:getData() ) do
		self:setNetworkVar( k, v )
	end
end

function entity:update( dt )
	if ( _CLIENT and not _SERVER and cl_interpolate:getBoolean() ) then
		self:updatePosition( self )
	end

	local body = self:getBody()
	if ( body and not body:isDestroyed() ) then
		self:setNetworkVar( "position", vector( body:getPosition() ) )
	end

	local currentMap = self:getMap()
	local map        = map.getAtPosition( self:getPosition() )
	if ( currentMap and currentMap ~= map ) then
		self:setMap( map )
	end

	if ( self.think     and
	     self.nextThink and
	     self.nextThink <= love.timer.getTime() ) then
		self.nextThink = nil
		self:think()
	end

	if ( _CLIENT ) then
		local sprite = self:getSprite()
		if ( type( sprite ) == "sprite" ) then
			sprite:update( dt )
		end
	end
end

function entity:updatePosition()
	local buffer = self._interpolationBuffer
	if ( buffer == nil ) then
		return
	end

	local cl_updaterate = convar.getConvar( "cl_updaterate" )
	local now = love.timer.getTime()
	local renderTimestamp = now - ( 1 / cl_updaterate:getNumber() )

	while ( #buffer >= 2 and buffer[ 2 ].time <= renderTimestamp ) do
		table.remove( buffer, 1 )
	end

	local body = self:getBody()
	if ( body == nil ) then
		return
	end

	if ( #buffer >= 2 and
	    buffer[ 1 ].time <= renderTimestamp and
	    renderTimestamp <= buffer[ 2 ].time ) then
		local p1 = buffer[ 1 ].value
		local p2 = buffer[ 2 ].value
		local t1 = buffer[ 1 ].time
		local t2 = buffer[ 2 ].time
		local dt = ( renderTimestamp - t1 ) / ( t2 - t1 )
		local x  = math.round( math.lerp( p1.x, p2.x, dt ) )
		local y  = math.round( math.lerp( p1.y, p2.y, dt ) )
		body:setPosition( x, y )
	end
end

function entity:use( activator, value )
end

function entity:__tostring()
	return "entity: " .. self.__type
end

concommand( "ent_create", "Creates an entity where the player is looking",
	function( self, player, command, argString, argTable )
		if ( not _SERVER ) then
			return
		end

		local entity = _G.entity.create( argString )
		if ( entity ) then
			local position = player:getPosition() + vector( 0, game.tileSize )
			entity:setPosition( position )
			entity:spawn()
		end
	end,

	{ "network", "cheat" },

	function( argS )
		local autocomplete = {}
		local entities = entities.getAll()
		for _, classname in pairs( entities ) do
			local cmd = "ent_create " .. classname
			if ( string.find( cmd, "ent_create " .. argS, 1, true ) ) then
				table.insert( autocomplete, cmd )
			end
		end

		table.sort( autocomplete )

		return autocomplete
	end
)
