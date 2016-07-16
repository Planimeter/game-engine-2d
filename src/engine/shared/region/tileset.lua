--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Region Tileset class
--
--============================================================================--

class( "regiontileset" )

function regiontileset:regiontileset( tilesetData )
	self.data = tilesetData
	self:parse()
end

mutator( regiontileset, "filename" )
mutator( regiontileset, "firstGid", "firstgid" )
mutator( regiontileset, "image" )
mutator( regiontileset, "imageWidth", "imagewidth" )
mutator( regiontileset, "imageHeight", "imageheight" )
mutator( regiontileset, "name" )
mutator( regiontileset, "properties" )
mutator( regiontileset, "spacing" )
mutator( regiontileset, "margin" )
mutator( regiontileset, "tileCount", "tilecount" )
mutator( regiontileset, "tileOffset", "tileoffset" )
mutator( regiontileset, "tiles" )
mutator( regiontileset, "tileWidth", "tilewidth" )
mutator( regiontileset, "tileHeight", "tileheight" )

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
