--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: Region class
--
--==========================================================================--

require( "engine.shared.hook" )

class( "region" )

region._regions = region._regions or {}

if ( _CLIENT ) then
	local function drawRegion( region )
		local worldIndex = camera.getWorldIndex()
		if ( worldIndex ~= region:getWorldIndex() ) then
			return
		end

		love.graphics.push()
			local x, y = region:getX(), region:getY()
			love.graphics.translate( x, y )
			region:draw()
		love.graphics.pop()
	end

	function region.drawWorld()
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

			-- Draw regions
			for _, region in ipairs( region._regions ) do
				drawRegion( region )
			end

			-- Draw entities
			entity.drawAll()
		love.graphics.pop()
	end
end

function region.exists( name )
	name = string.gsub( name, "%.", "/" )
	return love.filesystem.exists( "regions/" .. name .. ".lua" )
end

function region.findNextWorldIndex()
	local worldIndex = 1
	for _, region in ipairs( region._regions ) do
		if ( worldIndex == region:getWorldIndex() ) then
			worldIndex = worldIndex + 1
		end
	end

	return worldIndex
end

function region.getAll()
	return table.shallowcopy( region._regions )
end

function region.getByName( name )
	for _, region in ipairs( region._regions ) do
		if ( name == region:getName() ) then
			return region
		end
	end
end

function region.getAtPosition( position, worldIndex )
	worldIndex = worldIndex or 1
	for _, region in ipairs( region._regions ) do
		local px, py = position.x, position.y
		local x,  y  = region:getX(), region:getY()
		local width  = region:getPixelWidth()
		local height = region:getPixelHeight()
		if ( region.pointinrect( px, py, x, y, width, height ) ) then
			return region
		end
	end
end

function region.getWorld()
	return region._world
end

function region.load( name, x, y, worldIndex )
	x = x or 0
	y = y or 0
	if ( region.getByName( name ) ) then
		return
	end
	local region = region( name, x, y, worldIndex )
	table.insert( region._regions, region )
end

function region.reload( library )
	if ( string.sub( library, 1, 8 ) ~= "regions." ) then
		return
	end
	local name = string.gsub( library, "regions.", "" )
	local r = region.getByName( name )
	local x = r:getX()
	local y = r:getY()
	local worldIndex = r:getWorldIndex()
	-- TODO: Move players to new region.
	region.unload( name )
	region.load( name, x, y, worldIndex )
end

hook.set( "shared", region.reload, "onReloadScript", "reloadRegion" )

if ( _CLIENT ) then
	local function initializeTiles( region )
		for _, regionlayer in ipairs( region:getLayers() ) do
			if ( regionlayer:getType() == "tilelayer" ) then
				regionlayer:initializeTiles()
			end
		end
	end

	function region.reloadTiles( filename )
		if ( not string.find( filename, "images/tilesets/" ) ) then
			return
		end

		for _, region in ipairs( region._regions ) do
			initializeTiles( region )
		end
	end

	hook.set( "client", reloadTiles, "onReloadImage", "reloadTiles" )
end

function region.unload( name )
	unrequire( "regions." .. name )

	for i, region in ipairs( region._regions ) do
		if ( name == region:getName() ) then
			region:remove()
			table.remove( region._regions, i )
			return
		end
	end
end

function region.unloadAll()
	for i = #region._regions, 1, -1 do
		local region = region._regions[ i ]
		unrequire( "regions." .. region:getName() )
		table.remove( region._regions, i )
	end
end

region.shutdown = region.unloadAll

if ( not _DEDICATED ) then
	concommand( "region", "Loads the specified region",
		function( _, _, _, _, argT )
			local name = argT[ 1 ]
			if ( name == nil ) then
				print( "region <region name>" )
				return
			end

			if ( not region.exists( name ) ) then
				print( name .. " does not exist." )
				return
			end

			engine.client.disconnect()

			if ( not engine.client.initializeServer() ) then
				return
			end

			game.initialRegion = name

			engine.client.connectToListenServer()
		end,

		nil,

		function( argS )
			local autocomplete = {}
			local files = love.filesystem.getDirectoryItems( "regions" )
			for _, v in ipairs( files ) do
				if ( string.fileextension( v ) == "lua" ) then
					local name  = string.gsub( v, ".lua", "" )
					local cmd   = "region " .. name
					if ( string.find( cmd, "region " .. argS, 1, true ) ) then
						table.insert( autocomplete, cmd )
					end
				end
			end

			table.sort( autocomplete )

			return autocomplete
		end
	)
end

function region.pointinrect( px, py, x, y, width, height )
	return px >= x and
	       py  > y and
	       px  < x + width and
	       py <= y + height
end

function region.roundToGrid( x, y )
	local region = region.getAtPosition( vector( x, y ) )
	if ( region == nil ) then
		return x, y
	end

	local w, h = region:getTileSize()
	x = x - x % w + math.nearestmult( x % w, w )
	y = y - y % h + math.nearestmult( y % h, h )
	return x, y
end

function region.snapToGrid( x, y )
	local region = region.getAtPosition( vector( x, y ) )
	if ( region == nil ) then
		return x, y
	end

	local w, h = region:getTileSize()
	x = x - x % w
	y = y - y % h
	return x, y
end

function region:region( name, x, y, worldIndex )
	self.name = name
	self.data = require( "regions." .. name )

	self.x = x or 0
	self.y = y or 0
	self.worldIndex = worldIndex or 1

	self:parse()
end

if ( _CLIENT ) then
	function region:draw()
		local layers = self:getLayers()
		if ( layers == nil ) then
			return
		end

		for _, layer in ipairs( layers ) do
			if ( layer:isVisible() ) then
				layer:draw()
			end
		end
	end
end

function region:cleanup()
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

accessor( region, "entities" )

function region:getFilename()
	return string.gsub( self.name, "%.", "/" ) .. ".lua"
end

accessor( region, "formatVersion" )

local data = {}
local gid  = 0

function region:getGidsAtPosition( position )
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

accessor( region, "layers" )
accessor( region, "name" )
accessor( region, "orientation" )

function region:getPixelWidth()
	return self:getTileWidth() * self:getWidth()
end

function region:getPixelHeight()
	return self:getTileHeight() * self:getHeight()
end

accessor( region, "properties" )

function region:getTileset( layer )
	local gid = layer:getHighestTileGid()
	local tileset = nil
	for _, t in ipairs( self:getTilesets() ) do
		if ( t:getFirstGid() <= gid ) then
			tileset = t
		end
	end
	return tileset
end

accessor( region, "tilesets" )
accessor( region, "tileWidth" )
accessor( region, "tileHeight" )
accessor( region, "width" )
accessor( region, "height" )
accessor( region, "worldIndex" )
accessor( region, "x" )
accessor( region, "y" )

function region.initializeWorld()
	if ( region._world ) then
		return
	end

	region._world = love.physics.newWorld()
end

local px            = 0
local py            = 0
local x             = 0
local y             = 0
local width         = 0
local height        = 0
local pointinrect   = region.pointinrect
local gids          = {}
local firstGid      = 0
local tiles         = {}
local hasvalue      = table.hasvalue
local hasProperties = false
local properties    = {}
local walkable      = nil

function region:isTileWalkableAtPosition( position )
	-- Check world bounds
	px     = position.x
	py     = position.y
	x      = self:getX()
	y      = self:getY()
	width  = self:getPixelWidth()
	height = self:getPixelHeight()
	if ( not pointinrect( px, py, x, y, width, height ) ) then
		-- No, but check nearby region
		local tilePosition = vector( px, py )
		local worldIndex   = self:getWorldIndex()
		local region       = region.getAtPosition( tilePosition, worldIndex )
		if ( region ) then
			return region:isTileWalkableAtPosition( position )
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
			walkable      = hasProperties and properties.walkable
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

function region:loadTilesets( tilesets )
	if ( self.tilesets ) then
		return
	end

	self.tilesets = {}

	require( "engine.shared.region.tileset" )
	for _, tilesetData in ipairs( tilesets ) do
		local tileset = region.tileset( self, tilesetData )
		table.insert( self.tilesets, tileset )
	end
end

function region:loadLayers( layers )
	if ( self.layers ) then
		return
	end

	self.layers = {}

	require( "engine.shared.region.layer" )
	for _, layerData in ipairs( layers ) do
		local layer = region.layer( layerData )
		layer:setRegion( self )
		layer:parse()

		local tileset = self:getTileset( layer )
		layer:setTileset( tileset )
		table.insert( self.layers, layer )
	end
end

function region:parse()
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

	region.initializeWorld()
	self:loadTilesets( data[ "tilesets" ] )
	self:loadLayers( data[ "layers" ] )

	self.data = nil
end

function region:remove()
	self:cleanup()

	local world = self:getWorld()
	if ( world and #region._regions == 1 ) then
		world:destroy()
		region._world = nil
	end
end

function region:removeEntity( entity )
	local entities = self:getEntities()
	if ( entities ) then
		for i, v in ipairs( entities ) do
			if ( v == entity ) then
				table.remove( entities, i )
			end
		end
	end
end

function region:getTileSize()
	return self:getTileWidth(), self:getTileHeight()
end

function region.update( dt )
	local world = region.getWorld()
	if ( world ) then
		world:update( dt )
	end
end

function region:__tostring()
	return "region: \"" .. self:getFilename() .. "\""
end
