--========= Copyright © 2013-2014, Planimeter, All rights reserved. ==========--
--
-- Purpose: Entities interface
--
--============================================================================--

local _SERVER	= _SERVER

local _entities = entities and entities.entities or {}
local getfenv	= getfenv
local ipairs	= ipairs
local pcall		= pcall
local print		= print
local require	= require
local string	= string
local _G		= _G

module( "entities" )

entities = _entities

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
