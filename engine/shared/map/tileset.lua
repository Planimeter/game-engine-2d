--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: Map Tileset class
--
--==========================================================================--

class( "map.tileset" )

local tileset = map.tileset

function tileset:tileset( map, tilesetData )
	self:setMap( map )
	self.data = tilesetData
	self:parse()
end

accessor( tileset, "filename" )
accessor( tileset, "firstGid", nil, "firstgid" )
accessor( tileset, "image" )
accessor( tileset, "imageWidth", nil, "imagewidth" )
accessor( tileset, "imageHeight", nil, "imageheight" )
accessor( tileset, "name" )
accessor( tileset, "properties" )
accessor( tileset, "map" )
accessor( tileset, "spacing" )
accessor( tileset, "margin" )
accessor( tileset, "tileCount", nil, "tilecount" )
accessor( tileset, "tileOffset", nil, "tileoffset" )
accessor( tileset, "tiles" )
accessor( tileset, "tileWidth", nil, "tilewidth" )
accessor( tileset, "tileHeight", nil, "tileheight" )

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
		local mapsDir = "maps/"
		local map     = self:getMap()
		local path       = string.stripfilename( map:getFilename() )
		mapsDir       = mapsDir .. path
		path             = mapsDir .. data[ "image" ]
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
	self.image:setFilter( "nearest", "nearest" )
end

function tileset:__tostring()
	return "tileset: \"" .. self:getName() .. "\""
end
