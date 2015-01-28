--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Region Tileset class
--
--============================================================================--

class( "regiontileset" )

function regiontileset:regiontileset( tilesetData )
	self.data = tilesetData

	self:parse()
end

function regiontileset:getFirstGid()
	return self.firstgid
end

function regiontileset:getImage()
	return self.image
end

function regiontileset:getImageWidth()
	return self.imagewidth
end

function regiontileset:getImageHeight()
	return self.imageheight
end

function regiontileset:getName()
	return self.name
end

function regiontileset:getProperties()
	return self.properties
end

function regiontileset:getSpacing()
	return self.spacing
end

function regiontileset:getMargin()
	return self.margin
end

function regiontileset:getTiles()
	return self.tiles
end

function regiontileset:getTileWidth()
	return self.tilewidth
end

function regiontileset:getTileHeight()
	return self.tileheight
end

function regiontileset:parse()
	if ( not self.data ) then
		return
	end

	local data = self.data
	self:setName( data[ "name" ] )
	self:setFirstGid( data[ "firstgid" ] )
	self:setTileWidth( data[ "tilewidth" ] )
	self:setTileHeight( data[ "tileheight" ] )
	self:setSpacing( data[ "spacing" ] )
	self:setMargin( data[ "margin" ] )
	if ( _CLIENT ) then
		self:setImage( string.sub( data[ "image" ], 4 ) )
	end
	self:setImageWidth( data[ "imagewidth" ] )
	self:setImageHeight( data[ "imageheight" ] )
	self:setProperties( table.copy( data[ "properties" ] ) )
	self:setTiles( table.copy( data[ "tiles" ] ) )

	self.data = nil
end

function regiontileset:setFirstGid( firstgid )
	self.firstgid = firstgid
end

function regiontileset:setImage( image )
	self.image = graphics.newImage( image )
end

function regiontileset:setImageWidth( imagewidth )
	self.imagewidth = imagewidth
end

function regiontileset:setImageHeight( imageheight )
	self.imageheight = imageheight
end

function regiontileset:setName( name )
	self.name = name
end

function regiontileset:setProperties( properties )
	self.properties = properties
end

function regiontileset:setSpacing( spacing )
	self.spacing = spacing
end

function regiontileset:setMargin( margin )
	self.margin = margin
end

function regiontileset:setTiles( tiles )
	self.tiles = tiles
end

function regiontileset:setTileWidth( tilewidth )
	self.tilewidth = tilewidth
end

function regiontileset:setTileHeight( tileheight )
	self.tileheight = tileheight
end

function regiontileset:__tostring()
	return "regiontileset: \"" .. self:getName() .. "\""
end
