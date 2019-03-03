--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
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

	function layer:draw()
		if ( self:getType() ~= "tilelayer" ) then
			return
		end

		local spritebatch = self:getSpriteBatch()
		if ( spritebatch == nil ) then
			return
		end

		love.graphics.push()
			love.graphics.translate( self:getX(), self:getY() )
			love.graphics.setColor( color( color.white, self:getOpacity() * 255 ) )
			love.graphics.draw( spritebatch )
		love.graphics.pop()
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

if ( _CLIENT ) then
	accessor( layer, "spriteBatch", nil, "spritebatch" )
end

accessor( layer, "tileset" )
accessor( layer, "type" )
accessor( layer, "width" )
accessor( layer, "height" )
accessor( layer, "x" )
accessor( layer, "y" )

if ( _CLIENT ) then
	function layer:initializeTiles()
		self:createSpriteBatch()

		local spritebatch = self:getSpriteBatch()
		if ( spritebatch == nil ) then
			return
		end

		local tileset  = self:getTileset()
		local tileW    = tileset:getTileWidth()
		local tileH    = tileset:getTileHeight()
		local image    = tileset:getImage()
		local imgW     = image:getWidth()
		local imgH     = image:getHeight()
		local quad     = love.graphics.newQuad( 0, 0, tileW, tileH, imgW, imgH )
		local id       = 0
		local tileX    = 0
		local tileY    = 0
		local firstgid = tileset:getFirstGid()
		local floor    = math.floor
		local x        = 0
		local y        = 0
		local width    = self:getWidth()
		local height   = self:getHeight()
		table.foreachi( self:getData(), function( xy, gid )
			if ( gid == 0 ) then
				return
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

function layer:setTileset( tileset )
	self.tileset = tileset

	if ( _CLIENT ) then
		if ( self:getType() == "tilelayer" ) then
			self:initializeTiles()
		end
	end
end

function layer:setVisible( visible )
	self.visible = visible
end

function layer:__tostring()
	return "layer: \"" .. self:getName() .. "\""
end
