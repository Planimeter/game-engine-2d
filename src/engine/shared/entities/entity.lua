--========= Copyright © 2013-2014, Planimeter, All rights reserved. ==========--
--
-- Purpose: Entity class
--
--============================================================================--

require( "common.vector" )
require( "engine.shared.entities.networkvar" )

-- These values are preserved during real-time scripting.
local entities	   = entity and entity.entities		or {}
local lastEntIndex = entity and entity.lastEntIndex or 0

class( "entity" )

entity.entities		= entities
entity.lastEntIndex = lastEntIndex

function entity.findByClassname( classname, region )
	local t = {}
	if ( region ) then
		region = _G.region.getByName( region )
		for i, entity in ipairs( region:getEntities() ) do
			if ( classname == entity:getClassname() ) then
				table.insert( t, entity )
			end
		end
	else
		for i, region in ipairs( _G.region.getAll() ) do
			for j, entity in ipairs( region:getEntities() ) do
				if ( classname == entity:getClassname() ) then
					table.insert( t, entity )
				end
			end
		end
	end
	return #t ~= 0 and t or nil
end

function entity:entity()
	self.entIndex		= entity.lastEntIndex + 1
	entity.lastEntIndex = self.entIndex
	self.name			= self:networkVar( "name",	   nil )
	self.position		= self:networkVar( "position", vector() )

	table.insert( entities, self )
end

function entity:getClassname()
	return self.__type
end

function entity:networkVar( name, initialValue )
	self.networkVars = self.networkVars or {}

	local networkvar = networkvar( self, name )
	networkvar:setValue( initialValue )
	self.networkVars[ name ] = networkvar

	local metatable	 = getmetatable( self )
	local getter	 = "get" .. string.capitalize( name )
	local setter	 = "set" .. string.capitalize( name )
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

function entity:onNetworkVarChanged( networkvar )
end

function entity:spawn()
	if ( _SERVER ) then
		-- TODO: Send entityCreated payload only to players who can see me.
		local payload = payload( "entitySpawned" )
		payload:set( "classname", self:getClassname() )
		payload:set( "entIndex", self.entIndex )
		engineserver.network.broadcast( payload:serialize() )
	end
end

function entity:__tostring()
	return "entity: " .. self.__type
end
