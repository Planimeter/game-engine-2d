--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Entity class
--
--============================================================================--

-- These values are preserved during real-time scripting.
local entities     = entity and entity.entities     or {}
local lastEntIndex = entity and entity.lastEntIndex or 0

require( "common.vector" )
require( "engine.shared.entities.networkvar" )

class( "entity" )

entity.entities     = entities
entity.lastEntIndex = lastEntIndex

function entity.create( classname )
	local classes = _G.entities.getClassMap()
	local entity  = classes[ classname ]()
	return entity
end

if ( _CLIENT ) then
	local clear       = table.clear
	local append      = table.append
	local renderables = {}

	local shallowcopy = function( from, to )
		for k, v in pairs( from ) do to[ k ] = v end
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

	local r_draw_shadows = convar( "r_draw_shadows", "1", nil, nil,
	                            "Draws entity shadows" )

	function entity.drawAll()
		clear( renderables )
		shallowcopy( entity.entities, renderables )
		append( renderables, camera.getWorldContexts() )
		depthSort( renderables )

		if ( r_draw_shadows:getBoolean() ) then
			for _, v in ipairs( renderables ) do
				graphics.push()
					local x, y = v:getDrawPosition()
					graphics.translate( camera.worldToScreen( x, y ) )

					-- Draw shadow
					local isEntity = typeof( v, "entity" )
					if ( isEntity ) then
						graphics.push()
							graphics.setOpacity( 0.14 )
							graphics.setColor( color.black )

							local sprite = v:getSprite()
							local height = sprite:getHeight()
							graphics.translate( -height, 0 )
								v:drawShadow()
							graphics.setOpacity( 1 )
						graphics.pop()
					end
				graphics.pop()
			end
		end

		-- TODO: Only draw renderables in viewport.
		for _, v in ipairs( renderables ) do
			graphics.push()
				local x, y = v:getDrawPosition()
				graphics.translate( camera.worldToScreen( x, y ) )

				-- Draw entity
				graphics.setColor( color.white )
				v:draw()
			graphics.pop()
		end
	end
end

function entity.findByClassname( classname, region )
	local t = {}
	if ( region ) then
		region = _G.region.getByName( region )
		local entities = region:getEntities()
		if ( entities ) then
			for i, entity in ipairs( region:getEntities() ) do
				if ( classname == entity:getClassname() ) then
					table.insert( t, entity )
				end
			end
		end
	else
		for i, region in ipairs( _G.region.getAll() ) do
			local entities = region:getEntities()
			if ( entities ) then
				for j, entity in ipairs( entities ) do
					if ( classname == entity:getClassname() ) then
						table.insert( t, entity )
					end
				end
			end
		end
	end
	return #t ~= 0 and t or nil
end

function entity.getAll()
	return table.shallowcopy( entity.entities )
end

function entity.getByEntIndex( entIndex )
	for _, v in pairs( entity.entities ) do
		if ( v.entIndex == entIndex ) then
			return v
		end
	end
end

function entity.removeAll()
	entity.entities = {}
end

function entity:entity()
	self.entIndex = entity.lastEntIndex + 1

	if ( _SERVER ) then
		entity.lastEntIndex = self.entIndex
	end

	self:networkString( "name",     nil )
	self:networkVector( "position", vector() )

	table.insert( entity.entities, self )
end

function entity:getClassname()
	return self.__type
end

function entity:getCollisionBounds()
	return self.boundsMin, self.boundsMax
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

	function entity:getLocalPosition()
		return self.localPosition
	end
end

function entity:getName()
	return self:getNetworkVar( "name" )
end

function entity:getPosition()
	return self:getNetworkVar( "position" )
end

if ( _CLIENT ) then
	function entity:getSprite()
		return self.sprite or graphics.error
	end

	function entity:draw()
		local sprite = self:getSprite()
		graphics.draw( sprite:getDrawable() )
	end

	function entity:drawShadow()
		local sprite = self:getSprite()
		local scale  = 1
		graphics.draw( sprite:getDrawable(), 0, 0, 0, 1, scale, 0, 0, scale )
	end
end

function entity:networkVar( name, initialValue )
	self.networkVars = self.networkVars or {}

	local networkvar = networkvar( self, name )
	networkvar:setValue( initialValue )
	self.networkVars[ name ] = networkvar
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
				table.insert( keys, { name = name, type = type } )
			end

			self:networkVar( name, initialValue )
		end
	end
end

function entity:setNetworkVar( name, value )
	if ( self.networkVars[ name ] == nil ) then
		error( "attempt to set nonexistent networkvar '" .. name .. "'", 2 )
	end

	self.networkVars[ name ]:setValue( value )
end

function entity:getNetworkVar( name )
	if ( self.networkVars[ name ] == nil ) then
		return nil
	end

	return self.networkVars[ name ]:getValue()
end

function entity:getNetworkVarsStruct()
	if ( not self.networkVarsStruct ) then
		local struct = {
			keys = {}
		}
		local class = getmetatable( self )
		while ( getbaseclass( class ) ) do
			local keys = rawget( class, "networkVarKeys" )
			if ( keys ) then
				for i, key in ipairs( keys ) do
					table.insert( struct.keys, key )
				end
			end
			class = getbaseclass( class )
		end
		self.networkVarsStruct = struct
	end
	return self.networkVarsStruct
end

function entity:getNetworkVarTypeLenValues()
	local struct      = self:getNetworkVarsStruct()
	local networkVars = typelenvalues( nil, struct )
	for k, v in pairs( self.networkVars ) do
		networkVars:set( k, v:getValue() )
	end
	return networkVars
end

function entity:onNetworkVarChanged( networkvar )
	if ( _SERVER ) then
		local payload = payload( "networkVarChanged" )
		payload:set( "entIndex", self.entIndex )

		local struct = self:getNetworkVarsStruct()
		local networkVar = typelenvalues( nil, struct )
		networkVar:set( networkvar:getName(), networkvar:getValue() )
		payload:set( "networkVars", networkVar )

		networkserver.broadcast( payload )
	end
end

function entity:remove()
	for i, v in pairs( entity.entities ) do
		if ( v == self ) then
			table.remove( entity.entities, i )
		end
	end

	if ( _SERVER and not _CLIENT ) then
		local payload = payload( "entityRemoved" )
		payload:set( "entIndex", self.entIndex )
		networkserver.broadcast( payload )
	end
end

if ( _CLIENT ) then
	local function onEntityRemoved( payload )
		local entIndex = payload:get( "entIndex" )
		local entity   = entity.getByEntIndex( entIndex )
		if ( entity ) then
			entity:remove()
		end
	end

	payload.setHandler( onEntityRemoved, "entityRemoved" )
end

function entity:setCollisionBounds( min, max )
	self.boundsMin = min
	self.boundsMax = max
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

if ( _CLIENT ) then
	function entity:setSprite( sprite )
		self.sprite = sprite
	end
end

function entity:spawn()
	if ( _SERVER ) then
		-- TODO: Send entityCreated payload only to players who can see me.
		local payload = payload( "entitySpawned" )
		payload:set( "classname", self:getClassname() )
		payload:set( "entIndex", self.entIndex )
		payload:set( "networkVars", self:getNetworkVarTypeLenValues() )
		networkserver.broadcast( payload )
	end
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

function entity:__tostring()
	return "entity: " .. self.__type
end
