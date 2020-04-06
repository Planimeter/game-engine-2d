--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Map Layer class
--
--==========================================================================--

class( "map.layer" )

local layer = map.layer

function layer:layer( layerData )
	self.data = layerData
end

if ( _CLIENT ) then
	function layer:createSpriteBatch()
		local tileset = self:getTileset()
		if ( tileset == nil ) then
			return
		end

		local image = tileset:getImage()
		local count = self:getWidth() * self:getHeight()
		self.spritebatch = love.graphics.newSpriteBatch( image, count )
	end
end

accessor( layer, "data" )

function layer:getHighestTileGid()
	local highestTileGid = -1
	for xy, gid in ipairs( self:getData() ) do
		if ( gid >= highestTileGid ) then
			highestTileGid = gid
		end
	end
	return highestTileGid
end

accessor( layer, "name" )
accessor( layer, "opacity" )
accessor( layer, "properties" )
accessor( layer, "map" )

accessor( layer, "tileset" )
accessor( layer, "type" )
accessor( layer, "width" )
accessor( layer, "height" )
accessor( layer, "x" )
accessor( layer, "y" )

if ( _CLIENT ) then
	function layer:initializeTiles()
		self.spriteBatches = {}

		local id, firstgid, tileX, tileY, x, y, tileset, tileW, tileH, image, imgW, imgH, quad
		local floor    = math.floor
		local width = self:getWidth()
		local height = self:getHeight()
		local spritebatchCount = width * height
		local mapTileSets = self:getMap().tilesets
		table.foreachi( self:getData(), function( xy, gid )
			if ( gid == 0 ) then
				return
			end

			tileset = nil
			for i, set in ipairs(mapTileSets) do
				firstgid = set:getFirstGid()
				if (gid >= firstgid and gid < firstgid + set:getTileCount()) then
					tileset = set
					break
				end
			end

			assert(tileset ~= nil, string.format("Unable to find tileset for GID %i in layer %s", gid, self:getName()))

			tileW = tileset:getTileWidth()
			tileH = tileset:getTileHeight()
			image = tileset:getImage()
			imgW  = image:getWidth()
			imgH  = image:getHeight()
			quad  = love.graphics.newQuad( 0, 0, tileW, tileH, imgW, imgH )

			local spritebatch = self.spriteBatches[tileset:getName()]
			if (spritebatch == nil) then
				spritebatch = love.graphics.newSpriteBatch( image, spritebatchCount )
				self.spriteBatches[tileset:getName()] = spritebatch
			end

			id    = gid - firstgid
			tileX =      ( id * tileW % imgW )
			tileY = floor( id * tileW / imgW ) * tileH
			quad:setViewport( tileX, tileY, tileW, tileH )

			x =      ( ( xy - 1 ) % width ) * tileW
			y = floor( ( xy - 1 ) / width ) * tileH
			spritebatch:add( quad, self:getX() + x, self:getY() + y )
		end )
	end

	function layer:draw()
		if ( self:getType() ~= "tilelayer" ) then
			return
		end

		love.graphics.push()
			love.graphics.translate( self:getX(), self:getY() )
			love.graphics.setColor( color( color.white, self:getOpacity() * 255 ) )

			for _, spritebatch in pairs(self.spriteBatches) do
				love.graphics.draw( spritebatch )
			end
		love.graphics.pop()
	end
end

accessor( layer, "visible", "is" )

function layer:parse()
	if ( self.data == nil ) then
		return
	end

	local data = self.data
	self:setType( data[ "type" ] )
	self:setName( data[ "name" ] )
	self:setX( data[ "x" ] )
	self:setY( data[ "y" ] )
	self:setWidth( data[ "width" ] )
	self:setHeight( data[ "height" ] )
	self:setVisible( data[ "visible" ] )
	self:setOpacity( data[ "opacity" ] )
	self:setProperties( table.copy( data[ "properties" ] ) )

	local type = self:getType()
	if ( type == "tilelayer" ) then
		self:setData( table.copy( data[ "data" ] ) )

		if (_CLIENT) then
			self:initializeTiles()
		end

		return
	end

	if ( type == "objectgroup" ) then
		if ( not self:isVisible() ) then
			return
		end

		if ( _SERVER ) then
			require( "engine.shared.entities" )
			local map = self:getMap()
			local entities = entities.initialize( map, data[ "objects" ] )
			for _, entity in ipairs( entities ) do
				entity:setMap( map )
			end
		end

		return
	end

	-- self.data = nil
end

function layer:setVisible( visible )
	self.visible = visible
end

function layer:__tostring()
	return "layer: \"" .. self:getName() .. "\""
end
