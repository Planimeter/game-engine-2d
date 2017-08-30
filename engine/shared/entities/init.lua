--=========== Copyright © 2017, Planimeter, All rights reserved. ===========--
--
-- Purpose: Entities interface
--
--==========================================================================--

local getfenv   = getfenv
local ipairs    = ipairs
local love      = love
local pairs     = pairs
local payload   = payload
local pcall     = pcall
local print     = print
local require   = require
local string    = string
local table     = table
local unrequire = unrequire
local _G        = _G

module( "entities" )

_entities = _entities or {}
_classes  = _classes  or {}

function initialize( region, regionEntities )
	local t = {}
	for i, entityData in ipairs( regionEntities ) do
		local entity = createFromRegionData( region, entityData )
		if ( entity ) then
			entity:setRegion( region )
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

function requireEntity( classname )
	if ( _classes[ classname ] ) then
		return
	end

	for _, module in ipairs( modules ) do
		local library = module .. ".entities." .. classname
		local status, err = pcall( require, library )
		if ( status == true ) then
			_classes[ classname ] = library
			break
		end

		local message = "module '" .. library .. "' not found:"
		local notFound = string.find( err, message ) ~= 1
		if ( notFound ) then
			print( err )
		end
	end
end

function unrequireEntity( classname )
	unrequire( _classes[ classname ] )
	_classes[ classname ] = nil
end

function createFromRegionData( region, entityData )
	local type = entityData.type
	requireEntity( type )

	if ( _entities[ type ] == nil ) then
		print( "Attempted to create unknown entity type " .. type .. "!" )
		return nil
	end

	local entity = _entities[ type ]()
	if ( entityData.name and entityData.name ~= "" ) then
		entity:setNetworkVar( "name", entityData.name )
	end

	local x = region:getX() + entityData.x
	local y = region:getY() + entityData.y + entityData.height
	entity:setNetworkVar( "position", _G.vector( x, y ) )

	local hasWidth = entity:hasNetworkVar( "width" )
	if ( hasWidth ) then
		entity:setNetworkVar( "width", entityData.width )
	end

	local hasHeight = entity:hasNetworkVar( "height" )
	if ( hasHeight ) then
		entity:setNetworkVar( "height", entityData.height )
	end

	if ( table.len( entityData.properties ) > 0 ) then
		entity:setProperties( entityData.properties )
	end

	return entity
end

function getAll()
	local classnames = {}
	for _, module in ipairs( modules ) do
		module = module .. ".entities"
		local dir = string.gsub( module, "%.", "/" )
		local files = love.filesystem.getDirectoryItems( dir )
		for _, v in ipairs( files ) do
			if ( not love.filesystem.isDirectory( dir .. v ) and
			     v ~= "init.lua" and
			     v ~= "networkvar.lua" and
			     string.fileextension( v ) == "lua" ) then
				local classname = string.gsub( v, ".lua", "" )
				table.insert( classnames, classname )
			end
		end
	end

	return classnames
end

function getClassMap()
	return _entities
end

function linkToClassname( class, classname )
	_entities[ classname ] = class
end

if ( _G._CLIENT ) then
	local function onEntitySpawned( payload )
		if ( _G._SERVER ) then
			return
		end

		local classname = payload:get( "classname" )
		requireEntity( classname )

		if ( _entities[ classname ] == nil ) then
			print( "Attempted to create unknown entity type " .. classname .. "!" )
			return
		end

		local entity = _entities[ classname ]()
		entity.entIndex = payload:get( "entIndex" )
		entity:updateNetworkVars( payload )
		entity:spawn()
	end

	payload.setHandler( onEntitySpawned, "entitySpawned" )

	local function onNetworkVarChanged( payload )
		if ( _G._SERVER ) then
			return
		end

		local entity = payload:get( "entity" )
		if ( entity ) then
			entity:updateNetworkVars( payload )
		end
	end

	payload.setHandler( onNetworkVarChanged, "networkVarChanged" )
end

function shutdown()
	if ( _G.entity ) then
		_G.entity.removeAll()
		_G.entity._lastEntIndex = 0
	end

	if ( _G.player ) then
		_G.player.removeAll()
		_G.player._lastPlayerId = 0
	end

	for classname, module in pairs( _classes ) do
		unrequireEntity( classname )
	end
end
