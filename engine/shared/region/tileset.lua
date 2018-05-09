--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: Region Tileset class
--
--==========================================================================--

class( "region.tileset" )

local tileset = region.tileset

function tileset:tileset( region, tilesetData )
	self:setRegion( region )
	self.data = tilesetData
	self:parse()
end

accessor( tileset, "filename" )
accessor( tileset, "firstGid", "firstgid" )
accessor( tileset, "image" )
accessor( tileset, "imageWidth", "imagewidth" )
accessor( tileset, "imageHeight", "imageheight" )
accessor( tileset, "name" )
accessor( tileset, "properties" )
accessor( tileset, "region" )
accessor( tileset, "spacing" )
accessor( tileset, "margin" )
accessor( tileset, "tileCount", "tilecount" )
accessor( tileset, "tileOffset", "tileoffset" )
accessor( tileset, "tiles" )
accessor( tileset, "tileWidth", "tilewidth" )
accessor( tileset, "tileHeight", "tileheight" )

function tileset:parse()
	if ( self.data == nil ) then
		return
	end

	local data = self.data
	self:setName( data[ "name" ] )
	self:setFirstGid( data[ "firstgid" ] )
	self:setFilename( data[ "filename" ] )
	self:setTileWidth( data[ "tilewidth" ] )
	self:setTileHeight( data[ "tileheight" ] )
	self:setSpacing( data[ "spacing" ] )
	self:setMargin( data[ "margin" ] )
	if ( _CLIENT ) then
		local regionsDir = "regions/"
		local region     = self:getRegion()
		local path       = string.stripfilename( region:getFilename() )
		regionsDir       = regionsDir .. path
		path             = regionsDir .. data[ "image" ]
		path             = string.stripdotdir( path )
		self:setImage( path )
	end
	self:setImageWidth( data[ "imagewidth" ] )
	self:setImageHeight( data[ "imageheight" ] )

	require( "common.vector" )
	self:setTileOffset( vector.copy( data[ "tileoffset" ] ) )

	self:setProperties( table.copy( data[ "properties" ] ) )
	self:setTileCount( data[ "tilecount" ] )
	self:setTiles( table.copy( data[ "tiles" ] ) )

	self.data = nil
end

function tileset:setImage( image )
	self.image = love.graphics.newImage( image )
end

function tileset:__tostring()
	return "tileset: \"" .. self:getName() .. "\""
end
