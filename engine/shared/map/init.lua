--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Map class
--
--==========================================================================--

require( "engine.shared.hook" )

class( "map" )

map._maps = map._maps or {}

if ( _CLIENT ) then
	local r_draw_world = convar( "r_draw_world", "1", nil, nil, "Draws world" )

	local function drawMap( map )
		local worldIndex = camera.getWorldIndex()
		if ( worldIndex ~= map:getWorldIndex() ) then
			return
		end

		love.graphics.push()
			local x, y = map:getX(), map:getY()
			love.graphics.translate( x, y )
			map:draw()
		love.graphics.pop()
	end

	function map.drawWorld()
		local r, g, b, a = love.graphics.getBackgroundColor()
		local width      = love.graphics.getWidth()
		local height     = love.graphics.getHeight()
		love.graphics.setColor( r, g, b, a )
		love.graphics.rectangle( "fill", 0, 0, width, height )
		love.graphics.push()
			-- Setup camera
			local scale = camera.getZoom()
			love.graphics.scale( scale )
			local x, y = camera.getTranslation()
			love.graphics.translate( x, y )

			-- Draw maps
			if ( r_draw_world:getBoolean() ) then
				for _, map in ipairs( map._maps ) do
					drawMap( map )
				end
			end

			-- Draw entities
			entity.drawAll()
		love.graphics.pop()
	end
end

function map.exists( name )
	name = string.gsub( name, "%.", "/" )
	return love.filesystem.getInfo( "maps/" .. name .. ".lua" ) ~= nil
end

function map.findNextWorldIndex()
	local worldIndex = 1
	for _, map in ipairs( map._maps ) do
		if ( worldIndex == map:getWorldIndex() ) then
			worldIndex = worldIndex + 1
		end
	end

	return worldIndex
end

function map.getAll()
	return table.shallowcopy( map._maps )
end

function map.getByName( name )
	for _, map in ipairs( map._maps ) do
		if ( name == map:getName() ) then
			return map
		end
	end
end

function map.getAtPosition( position, worldIndex )
	worldIndex = worldIndex or 1
	for _, map in ipairs( map._maps ) do
		local px, py = position.x, position.y
		local x,  y  = map:getX(), map:getY()
		local width  = map:getPixelWidth()
		local height = map:getPixelHeight()
		if ( map.pointinrect( px, py, x, y, width, height ) ) then
			return map
		end
	end
end

function map.getWorld()
	return map._world
end

function map.getGroundBody()
	return map._groundBody
end

function map.load( name, x, y, worldIndex )
	x = x or 0
	y = y or 0
	if ( map.getByName( name ) ) then
		return
	end
	local map = map( name, x, y, worldIndex )
	table.insert( map._maps, map )
end

function map.reload( library )
	if ( string.sub( library, 1, 8 ) ~= "maps." ) then
		return
	end
	local name = string.gsub( library, "maps.", "" )
	local r = map.getByName( name )
	local x = r:getX()
	local y = r:getY()
	local worldIndex = r:getWorldIndex()
	-- TODO: Move players to new map.
	map.unload( name )
	map.load( name, x, y, worldIndex )
end

hook.set( "shared", map.reload, "onReloadScript", "reloadMap" )

if ( _CLIENT ) then
	local function initializeTiles( map )
		for _, maplayer in ipairs( map:getLayers() ) do
			if ( maplayer:getType() == "tilelayer" ) then
				maplayer:initializeTiles()
			end
		end
	end

	function map.reloadTiles( filename )
		if ( not string.find( filename, "images/tilesets/" ) ) then
			return
		end

		for _, map in ipairs( map._maps ) do
			initializeTiles( map )
		end
	end

	hook.set( "client", reloadTiles, "onReloadImage", "reloadTiles" )
end

function map.unload( name )
	unrequire( "maps." .. name )

	for i, map in ipairs( map._maps ) do
		if ( name == map:getName() ) then
			map:remove()
			table.remove( map._maps, i )
			return
		end
	end
end

function map.unloadAll()
	for i = #map._maps, 1, -1 do
		local m = map._maps[ i ]
		map.unload( m:getName() )
	end
end

map.shutdown = map.unloadAll

if ( not _DEDICATED ) then
	concommand( "map", "Loads the specified map",
		function( _, _, _, _, argT )
			local name = argT[ 1 ]
			if ( name == nil ) then
				print( "map <map name>" )
				return
			end

			if ( not map.exists( name ) ) then
				print( name .. " does not exist." )
				return
			end

			engine.client.disconnect()

			if ( not engine.client.initializeServer() ) then
				return
			end

			game.initialMap = name

			engine.client.connectToListenServer()
		end,

		nil,

		function( argS )
			local autocomplete = {}
			local files = love.filesystem.getDirectoryItems( "maps" )
			for _, v in ipairs( files ) do
				if ( string.fileextension( v ) == "lua" ) then
					local name  = string.gsub( v, ".lua", "" )
					local cmd   = "map " .. name
					if ( string.find( cmd, "map " .. argS, 1, true ) ) then
						table.insert( autocomplete, cmd )
					end
				end
			end

			table.sort( autocomplete )

			return autocomplete
		end
	)
end

function map.pointinrect( px, py, x, y, width, height )
	return px >= x and
	       py  > y and
	       px  < x + width and
	       py <= y + height
end

function map.roundToGrid( x, y )
	local map = map.getAtPosition( vector( x, y ) )
	if ( map == nil ) then
		return x, y
	end

	local w, h = map:getTileSize()
	x = x - x % w + math.nearestmult( x % w, w )
	y = y - y % h + math.nearestmult( y % h, h )
	return x, y
end

function map.snapToGrid( x, y )
	local map = map.getAtPosition( vector( x, y ) )
	if ( map == nil ) then
		return x, y
	end

	local w, h = map:getTileSize()
	x = x - x % w
	y = y - y % h
	return x, y
end

function map:map( name, x, y, worldIndex )
	self.name = name
	self.data = require( "maps." .. name )

	self.x = x or 0
	self.y = y or 0
	self.worldIndex = worldIndex or 1

	self:parse()

	if ( _CLIENT ) then
		require( "engine.client.canvas" )
		local width  = self:getPixelWidth()
		local height = self:getPixelHeight()
		self.canvas  = canvas( width, height, { dpiscale = 1 } )
		self.canvas:setFilter( "nearest", "nearest" )
	end

	self.needsRedraw = true
end

if ( _CLIENT ) then
	function map:draw()
		local layers = self:getLayers()
		if ( layers == nil ) then
			return
		end

		local canvas = self:getCanvas()
		if ( self.needsRedraw ) then
			love.graphics.push()
			canvas:renderTo( function()
				love.graphics.origin()
				love.graphics.clear()
				for _, layer in ipairs( layers ) do
					if ( layer:isVisible() ) then
						layer:draw()
					end
				end
			end )
			love.graphics.pop()

			self.needsRedraw = false
		end

		love.graphics.setColor( color.white )
		canvas:draw()
	end

	accessor( map, "canvas" )
end

function map:cleanup()
	local entities = self:getEntities()
	if ( entities == nil ) then
		return
	end

	for i = #entities, 1, -1 do
		local entity = entities[ i ]
		if ( not typeof( entity, "player" ) ) then
			entity:remove()
		end
	end
end

accessor( map, "entities" )

function map:getFilename()
	return string.gsub( self.name, "%.", "/" ) .. ".lua"
end

accessor( map, "formatVersion" )

local data = {}
local gid  = 0

function map:getGidsAtPosition( position )
	-- Convert to local positions
	position         = vector.copy( position )
	position.x       = position.x - self:getX()
	position.y       = position.y - self:getY()

	local tileWidth  = self:getTileWidth()
	local tileHeight = self:getTileHeight()
	position.y       = position.y - tileHeight

	local x    = ( position.x / tileWidth )  + 1
	local y    = ( position.y / tileHeight ) * self:getWidth()
	local xy   = x + y
	local gids = {}
	for _, layer in ipairs( self:getLayers() ) do
		data = layer:getData()
		gid = data[ xy ]
		table.insert( gids, gid )
	end
	return gids
end

accessor( map, "layers" )
accessor( map, "name" )
accessor( map, "orientation" )

function map:getPixelWidth()
	return self:getTileWidth() * self:getWidth()
end

function map:getPixelHeight()
	return self:getTileHeight() * self:getHeight()
end

accessor( map, "properties" )

accessor( map, "tilesets" )
accessor( map, "tileWidth" )
accessor( map, "tileHeight" )
accessor( map, "width" )
accessor( map, "height" )
accessor( map, "worldIndex" )
accessor( map, "x" )
accessor( map, "y" )

local function beginContact( a, b, contact )
	a = a:getUserData()
	b = b:getUserData()
	if ( a ) then
		a:startTouch( b, contact )
	end
end

local function endContact( a, b, contact )
	a = a:getUserData()
	b = b:getUserData()
	if ( a ) then
		a:endTouch( b, contact )
	end
end

local function preSolve( a, b, contact )
end

local function postSolve( a, b, contact, normalimpulse, tangentimpulse )
end

function map.initializeWorld()
	if ( map._world ) then
		return
	end

	map._world  = love.physics.newWorld()
	map._groundBody = love.physics.newBody( map.getWorld(), 0, 0 )

	local world = map.getWorld()
	world:setCallbacks( beginContact, endContact, preSolve, postSolve )
end

function map:initializePhysics()
	-- If the map has trigger_transitions, let level designers set
	-- up nodraws themselves.
	require( "engine.shared.entities.entity" )
	if ( entity.findByClassname( "trigger_transition", self ) ) then
		return false
	end

	local x       = self:getX()
	local y       = self:getY()
	local width   = self:getPixelWidth()
	local height  = self:getPixelHeight()
	local ground  = map.getGroundBody()

	-- Top boundary
	local shape   = love.physics.newEdgeShape( x + 0, y + 0, x + width, y + 0 )
	local fixture = love.physics.newFixture( ground, shape )

	-- Right boundary
	shape         = love.physics.newEdgeShape( x + width, y + 0, x + width, y + height )
	fixture       = love.physics.newFixture( ground, shape )

	-- Bottom boundary
	shape         = love.physics.newEdgeShape( x + width, y + height, x + 0, y + height )
	fixture       = love.physics.newFixture( ground, shape )

	-- Left boundary
	shape         = love.physics.newEdgeShape( x + 0, y + height, x + 0, y + 0 )
	fixture       = love.physics.newFixture( ground, shape )
end

local px            = 0
local py            = 0
local x             = 0
local y             = 0
local width         = 0
local height        = 0
local pointinrect   = map.pointinrect
local gids          = {}
local firstGid      = 0
local tiles         = {}
local hasvalue      = table.hasvalue
local hasProperties = false
local properties    = {}
local walkable      = nil

function map:isTileWalkableAtPosition( position )
	-- Check world bounds
	px     = position.x
	py     = position.y
	x      = self:getX()
	y      = self:getY()
	width  = self:getPixelWidth()
	height = self:getPixelHeight()
	if ( not pointinrect( px, py, x, y, width, height ) ) then
		-- No, but check nearby map
		local tilePosition = vector( px, py )
		local worldIndex   = self:getWorldIndex()
		local map          = map.getAtPosition( tilePosition, worldIndex )
		if ( map ) then
			return map:isTileWalkableAtPosition( position )
		else
			return false
		end
	end

	-- Check world collisions
	gids = self:getGidsAtPosition( position )
	for _, tileset in ipairs( self:getTilesets() ) do
		firstGid = tileset:getFirstGid()
		tiles    = tileset:getTiles()
		for _, tile in ipairs( tiles ) do
			hasProperties = hasvalue( gids, tile.id + firstGid )
			properties    = tile.properties
			walkable      = hasProperties and properties and properties.walkable
			if ( hasProperties and walkable == false ) then
				return false
			end
		end
	end

	-- Check entity collisions
	py = py - game.tileSize
	local entities = self:getEntities()
	if ( entities ) then
		for _, entity in ipairs( entities ) do
			local body = entity:getBody()
			if ( entity:testPoint(
				px + game.tileSize / 2,
				py + game.tileSize / 2
			) and ( body and body:getType() == "static" ) ) then
				return false
			end
		end
	end

	return true
end

function map:loadTilesets( tilesets )
	if ( self.tilesets ) then
		return
	end

	self.tilesets = {}

	require( "engine.shared.map.tileset" )
	for _, tilesetData in ipairs( tilesets ) do
		local tileset = map.tileset( self, tilesetData )
		table.insert( self.tilesets, tileset )
	end
end

function map:loadLayers( layers )
	if ( self.layers ) then
		return
	end

	self.layers = {}

	require( "engine.shared.map.layer" )
	for _, layerData in ipairs( layers ) do
		local layer = map.layer( layerData )
		layer:setMap( self )
		layer:parse()
		table.insert( self.layers, layer )
	end
end

function map:parse()
	if ( self.data == nil ) then
		return
	end

	local data = self.data
	self:setFormatVersion( data[ "version" ] )
	self:setOrientation( data[ "orientation" ] )
	self:setWidth( data[ "width" ] )
	self:setHeight( data[ "height" ] )
	self:setTileWidth( data[ "tilewidth" ] )
	self:setTileHeight( data[ "tileheight" ] )
	self:setProperties( table.copy( data[ "properties" ] ) )

	map.initializeWorld()
	-- self:initializePhysics()

	self:loadTilesets( data[ "tilesets" ] )
	self:loadLayers( data[ "layers" ] )

	-- NOTE: Do this here to detect trigger_transitions, instead.
	self:initializePhysics()

	self.data = nil
end

function map:remove()
	self:cleanup()

	local world = map.getWorld()
	if ( world and #map._maps == 1 ) then
		local ground = map.getGroundBody()
		ground:destroy()
		map._groundBody = nil

		world:destroy()
		map._world = nil
	end
end

function map:removeEntity( entity )
	local entities = self:getEntities()
	if ( entities == nil ) then
		return
	end

	for i, v in ipairs( entities ) do
		if ( v == entity ) then
			table.remove( entities, i )
		end
	end
end

function map:getTileSize()
	return self:getTileWidth(), self:getTileHeight()
end

function map.tick( timestep )
	local world = map.getWorld()
	if ( world ) then
		world:update( timestep )
	end
end

function map:__tostring()
	return "map: \"" .. self:getFilename() .. "\""
end
