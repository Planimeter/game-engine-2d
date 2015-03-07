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
			return a:getPosition().y < b:getPosition().y
		end )
	end

	function entity.drawAll()
		clear( renderables )
		shallowcopy( entity.entities, renderables )
		append( renderables, camera.getWorldContexts() )
		depthSort( renderables )

		-- TODO: Only draw renderables in viewport.
		for _, v in ipairs( renderables ) do
			graphics.push()
				local position = v:getPosition()
				local x, y = position.x, position.y
				if ( typeof( v, "entity" ) ) then
					local sprite = v:getSprite()
					local height = sprite:getHeight()
					y = y - height
				end
				graphics.translate( camera.worldToScreen( x, y ) )
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
	for _, v in ipairs( entity.entities ) do
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
	self:networkNumber( "scale",    1 )

	table.insert( entity.entities, self )
end

function entity:getClassname()
	return self.__type
end

if ( _CLIENT ) then
	function entity:getSprite()
		return self.sprite or graphics.error
	end

	function entity:draw()
		graphics.scale( self:getScale() )
		graphics.draw( self:getSprite():getDrawable() )
	end
end

function entity:networkVar( name, initialValue )
	self.networkVars = self.networkVars or {}

	local networkvar = networkvar( self, name )
	networkvar:setValue( initialValue )
	self.networkVars[ name ] = networkvar

	local metatable = getmetatable( self )
	local getter    = "get" .. string.capitalize( name )
	local setter    = "set" .. string.capitalize( name )
	if ( not metatable[ getter ] ) then
		metatable[ getter ] = function( self )
			return self:getNetworkVar( name )
		end
	end

	if ( not metatable[ setter ] ) then
		metatable[ setter ] = function( self, value )
			self:setNetworkVar( name, value )
		end
	end
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
			local mt = getmetatable( self )
			mt.networkVarKeys = mt.networkVarKeys or {}

			local keys      = mt.networkVarKeys
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
		while ( class.__base ) do
			local keys = class.networkVarKeys
			if ( keys ) then
				for i, key in ipairs( keys ) do
					table.insert( struct.keys, key )
				end
			end
			class = class.__base
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
		payload:set( "networkVar", networkVar )

		networkserver.broadcast( payload:serialize() )
	end
end

function entity:remove()
	for i, v in pairs( entity.entities ) do
		if ( v == self ) then
			table.remove( entity.entities, i )
			return
		end
	end
end

if ( _CLIENT ) then
	function entity:setSprite( sprite )
		self.sprite = sprite
	end
end

function entity:spawn()
	if ( self.spawned ) then
		return
	else
		self.spawned = true
	end

	if ( _SERVER ) then
		-- TODO: Send entityCreated payload only to players who can see me.
		local payload = payload( "entitySpawned" )
		payload:set( "classname", self:getClassname() )
		payload:set( "entIndex", self.entIndex )
		payload:set( "networkVars", self:getNetworkVarTypeLenValues() )
		networkserver.broadcast( payload:serialize() )
	end
end

function entity:__tostring()
	return "entity: " .. self.__type
end
