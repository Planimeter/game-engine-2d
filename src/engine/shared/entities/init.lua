--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Entities interface
--
--============================================================================--

-- These values are preserved during real-time scripting.
local _entities = entities and entities.entities or {}
local _classes  = entities and entities.classes  or {}

local _CLIENT	= _CLIENT
local _SERVER	= _SERVER

local getfenv	= getfenv
local ipairs	= ipairs
local pairs		= pairs
local payload	= payload
local pcall		= pcall
local print		= print
local require	= require
local string	= string
local table     = table
local unrequire	= unrequire
local _G		= _G

module( "entities" )

entities = _entities
classes  = _classes

function initialize( regionEntities )
	local t = {}
	for i, entityData in ipairs( regionEntities ) do
		local entity = createFromRegionData( entityData )
		if ( entity ) then
			entity:spawn()
			table.insert( t, entity )
		end
	end
	return t
end

local modules = {
	"engine.shared",
	"engine.server",
	"engine.client",
	"game.shared",
	"game.server",
	"game.client"
}

local find = string.find

function requireEntity( classname )
	local library
	local status, err
	for i, module in ipairs( modules ) do
		library = module .. ".entities." .. classname
		status, err = pcall( require, library )
		if ( status == true ) then
			classes[ classname ] = library
			return
		elseif ( status == false and
				 find( err, "module '" .. library .. "' not found:" ) ~= 1 ) then
			print( err )
		end
	end
end

if ( _SERVER ) then
	function createFromRegionData( entityData )
		local type = entityData.type
		requireEntity( type )

		if ( not entities[ type ] ) then
			print( "Attempted to create unknown entity type " .. type .. "!" )
			return nil
		end

		local entity = entities[ type ]()
		entity:setName( entityData.name )
		require( "common.vector" )
		entity:setPosition( _G.vector( entityData.x, entityData.y ) )
		return entity
	end
end

function getClassMap()
	return entities
end

function linkToClassname( class, classname )
	entities[ classname ] = class
	getfenv( 2 )[ classname ] = nil
end

if ( _CLIENT ) then
	local function onEntitySpawned( payload )
		if ( _SERVER ) then
			return
		end

		local classname = payload:get( "classname" )
		requireEntity( classname )

		if ( not entities[ classname ] ) then
			print( "Attempted to create unknown entity type " .. classname .. "!" )
			return
		end

		local entity	  = entities[ classname ]()
		entity.entIndex	  = payload:get( "entIndex" )

		local struct	  = entity:getNetworkVarsStruct()
		local networkVars = payload:get( "networkVars" )
		networkVars:setStruct( struct )
		networkVars:deserialize()
		for k, v in pairs( networkVars:getData() ) do
			entity[ "set" .. string.capitalize( k ) ]( entity, v )
		end

		if ( not _SERVER ) then
			entity:spawn()
		end
	end

	payload.setHandler( onEntitySpawned, "entitySpawned" )

	local function onNetworkVarChanged( payload )
		if ( _SERVER ) then
			return
		end

		local entIndex = payload:get( "entIndex" )
		require( "engine.shared.entities.entity" )
		local entity = _G.entity.getByEntIndex( entIndex )
		if ( entity ) then
			local struct	 = entity:getNetworkVarsStruct()
			local networkVar = payload:get( "networkVar" )
			networkVar:setStruct( struct )
			networkVar:deserialize()
			for k, v in pairs( networkVar:getData() ) do
				entity[ "set" .. string.capitalize( k ) ]( entity, v )
			end
		end
	end

	payload.setHandler( onNetworkVarChanged, "networkVarChanged" )
end

function shutdown()
	_G.entity.removeAll()
	_G.entity.lastEntIndex = 0
	_G.player.lastPlayerId = 0

	for classname, module in pairs( classes ) do
		unrequire( module )
	end
end
