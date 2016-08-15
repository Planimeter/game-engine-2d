--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Region Tileset class
--
--============================================================================--

class( "regiontileset" )

function regiontileset:regiontileset( tilesetData )
	self.data = tilesetData
	self:parse()
end

accessor( regiontileset, "filename" )
accessor( regiontileset, "firstGid", "firstgid" )
accessor( regiontileset, "image" )
accessor( regiontileset, "imageWidth", "imagewidth" )
accessor( regiontileset, "imageHeight", "imageheight" )
accessor( regiontileset, "name" )
accessor( regiontileset, "properties" )
accessor( regiontileset, "spacing" )
accessor( regiontileset, "margin" )
accessor( regiontileset, "tileCount", "tilecount" )
accessor( regiontileset, "tileOffset", "tileoffset" )
accessor( regiontileset, "tiles" )
accessor( regiontileset, "tileWidth", "tilewidth" )
accessor( regiontileset, "tileHeight", "tileheight" )

function regiontileset:parse()
	if ( not self.data ) then
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
		self:setImage( string.sub( data[ "image" ], 4 ) )
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

function regiontileset:setImage( image )
	self.image = graphics.newImage( image )
end

function regiontileset:__tostring()
	return "regiontileset: \"" .. self:getName() .. "\""
end
