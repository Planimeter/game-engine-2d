--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Region class
--
--============================================================================--

-- These values are preserved during real-time scripting.
local regions = region and region.regions or {}

require( "engine.shared.hook" )
require( "engine.shared.region.tileset" )
require( "engine.shared.region.layer" )

class( "region" )

region.regions = regions

if ( _CLIENT ) then
	function region.drawWorld()
		graphics.push()
			graphics.translate( camera.getTranslation() )
			for _, region in ipairs( region.regions ) do
				region:draw()
			end
		graphics.pop()
	end
end

function region.exists( name )
	return filesystem.exists( "regions/" .. name .. ".lua" )
end

function region.getAll()
	return table.shallowcopy( region.regions )
end

function region.getByName( name )
	for _, region in ipairs( region.regions ) do
		if ( name == region:getName() ) then
			return region
		end
	end
end

function region.getAtPosition( position )
	for _, region in ipairs( region.regions ) do
		local px, py = position.x, position.y
		-- TODO: Multiregion support.
		local x,  y  = 0, 0
		local width  = region:getWidth()  * region:getTileWidth()
		local height = region:getHeight() * region:getTileHeight()
		if ( math.pointInRectangle( px, py, x, y, width, height ) ) then
			return region
		end
	end
end

function region.load( name )
	if ( region.getByName( name ) ) then
		return
	end

	local region = region( name )
	table.insert( region.regions, region )
end

function region.reload( library )
	if ( string.sub( library, 1, 8 ) ~= "regions." ) then
		return
	end

	local name = string.gsub( library, "regions.", "" )
	local r    = region.getByName( name )
	r:cleanUp()
	region.unload( name )
	region.load( name )
end

hook.set( "shared", region.reload, "onReload", "reloadRegion" )

function region.unload( name )
	unrequire( "regions." .. name )

	for i, region in ipairs( region.regions ) do
		if ( name == region:getName() ) then
			table.remove( region.regions, i )
			return
		end
	end
end

function region.unloadAll()
	for i = #region.regions, 1, -1 do
		local region = region.regions[ i ]
		unrequire( "regions." .. region:getName() )
		table.remove( region.regions, i )
	end
end

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

		engine.disconnect()

		if ( _AXIS and not engine.isSignedIntoAxis() ) then
			print( "You are not signed into Axis." )
			return
		end

		local args = engine.getArguments()

		if ( _CLIENT and not _SERVER ) then
			_SERVER = true
			local status, ret = pcall( require, "engine.server" )
			if ( status ~= false ) then
				serverengine = ret
				if ( serverengine.load( args ) ) then
					game.call( "shared", "onLoad" )
				else
					print( "Failed to initialize server!" )
					engine.disconnect()
					_SERVER = nil
					return
				end
			else
				_SERVER = nil
				print( ret )
				return
			end
		end

		region.load( name )

		engine.connectToListenServer()
	end
)

function region.snapToGrid( x, y )
	local region = region.getAtPosition( vector( x, y ) )
	local w, h   = region:getTileSize()
	x = x - x % w
	y = y - y % h
	return x, y
end

function region:region( name )
	self.name = name
	self.data = require( "regions." .. name )

	self:parse()
end

if ( _CLIENT ) then
function region:draw()
	local layers = self:getLayers()
	if ( layers ) then
		for _, layer in ipairs( layers ) do
			graphics.push()
				graphics.setOpacity( layer:getOpacity() )
				if ( layer:isVisible() ) then
					layer:draw()
				end
				graphics.setOpacity( 1 )
			graphics.pop()
		end
	end
end
end

function region:cleanUp()
	local entities = self:getEntities()
	for _, entity in pairs( entities ) do
		entity:remove()
	end
end

function region:getEntities()
	return self.entities
end

function region:getFilename()
	return self.name .. ".lua"
end

function region:getFormatVersion()
	return self.formatVersion
end

function region:getLayers()
	return self.layers
end

function region:getName()
	return self.name
end

function region:getOrientation()
	return self.orientation
end

function region:getProperties()
	return self.properties
end

function region:getTilesets()
	return self.tilesets
end

function region:getTileWidth()
	return self.tileWidth
end

function region:getTileHeight()
	return self.tileHeight
end

function region:getWidth()
	return self.width
end

function region:getHeight()
	return self.height
end

function region:isTileWalkableAtPosition()
	-- TODO: Implement me.
	return true
end

function region:loadTilesets( tilesets )
	if ( self.tilesets ) then
		return
	end

	self.tilesets = {}

	for _, tilesetData in ipairs( tilesets ) do
		local tileset = regiontileset( tilesetData )
		table.insert( self.tilesets, tileset )
	end
end

function region:loadLayers( layers )
	if ( self.layers ) then
		return
	end

	self.layers = {}

	for _, layerData in ipairs( layers ) do
		local layer   = regionlayer( layerData )
		layer:setRegion( self )
		layer:parse()

		local gid     = layer:getHighestTileGid()
		local tileset = nil
		for _, t in ipairs( self:getTilesets() ) do
			if ( t:getFirstGid() <= gid ) then
				tileset = t
			end
		end
		layer:setTileset( tileset )
		table.insert( self.layers, layer )
	end
end

function region:parse()
	if ( not self.data ) then
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

	self:loadTilesets( data[ "tilesets" ] )
	self:loadLayers( data[ "layers" ] )

	self.data = nil
end

function region:setEntities( entities )
	self.entities = entities
end

function region:setFormatVersion( formatVersion )
	self.formatVersion = formatVersion
end

function region:setName( name )
	self.name = name
end

function region:setOrientation( orientation )
	self.orientation = orientation
end

function region:setProperties( properties )
	self.properties = properties
end

function region:setTileWidth( tileWidth )
	self.tileWidth = tileWidth
end

function region:setTileHeight( tileHeight )
	self.tileHeight = tileHeight
end

function region:getTileSize()
	return self:getTileWidth(), self:getTileHeight()
end

function region:setWidth( width )
	self.width = width
end

function region:setHeight( height )
	self.height = height
end

function region:__tostring()
	return "region: \"" .. self:getFilename() .. "\""
end
