--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Region Tileset class
--
--============================================================================--

local accessor = accessor
local love     = love
local require  = require
local _CLIENT  = _CLIENT

module( "regiontileset", package.class )

function _M:regiontileset( tilesetData )
	self.data = tilesetData
	self:parse()
end

accessor( _M, "filename" )
accessor( _M, "firstGid", "firstgid" )
accessor( _M, "image" )
accessor( _M, "imageWidth", "imagewidth" )
accessor( _M, "imageHeight", "imageheight" )
accessor( _M, "name" )
accessor( _M, "properties" )
accessor( _M, "spacing" )
accessor( _M, "margin" )
accessor( _M, "tileCount", "tilecount" )
accessor( _M, "tileOffset", "tileoffset" )
accessor( _M, "tiles" )
accessor( _M, "tileWidth", "tilewidth" )
accessor( _M, "tileHeight", "tileheight" )

function _M:parse()
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

function _M:setImage( image )
	self.image = love.graphics.newImage( image )
end

function _M:__tostring()
	return "regiontileset: \"" .. self:getName() .. "\""
end
