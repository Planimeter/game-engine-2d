--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Image class
--
--============================================================================--

-- These values are preserved during real-time scripting.
local images = image and image.images or {}

local graphics = love.graphics

class( "image" )

image.images = images

local modtime  = nil
local errormsg = nil

local function reloadImage( i, filename )
	-- i.image = nil
	print( "Reloading " .. filename .. "..." )
	local status, ret = pcall( graphics.newImage, filename )
	i.modtime = modtime
	if ( status == false ) then
		print( ret )
	else
		i.image = ret

		if ( game ) then
			game.call( "client", "onReloadImage", filename )
		else
			require( "engine.shared.hook" )
			hook.call( "client", "onReloadImage", filename )
		end
	end
end

function image.update( dt )
	for filename, i in pairs( images ) do
		modtime, errormsg = filesystem.getLastModified( filename )
		if ( errormsg == nil and modtime ~= i.modtime ) then
			reloadImage( i, filename )
		end
	end
end

function image:image( filename )
	self:setFilename( filename )
end

function image:getDrawable()
	local filename = self:getFilename()
	if ( not filename ) then
		if ( self._image ) then
			return self._image
		else
			return _G.graphics.error:getDrawable()
		end
	end

	if ( not images[ filename ] ) then
		local image = graphics.newImage( filename )
		images[ filename ] = {
			image   = image,
			modtime = filesystem.getLastModified( filename )
		}
	end

	return images[ filename ].image
end

function image:getFilename()
	return self.filename
end

function image:getHeight()
	local image = self:getDrawable()
	return image:getHeight()
end

function image:getWidth()
	local image = self:getDrawable()
	return image:getWidth()
end

function image:getData()
	if ( not self._image ) then
		return nil
	end

	return self._image:getData()
end

function image:refresh()
	local image = self:getDrawable()
	return image:refresh()
end

function image:setImageData( imageData )
	if ( self._image ) then
		self._image:setImageData( imageData )
	else
		self._image = graphics.newImage( imageData )
	end
end

function image:setFilter( min, mag, anisotropy )
	local image = self:getDrawable()
	image:setFilter( min, mag, anisotropy )
end

local function getHighResolutionVariant( filename )
	local extension = "." .. string.fileextension( filename )
	local hrvariant = string.gsub( filename, extension, "" )
	hrvariant       = hrvariant .. "@2x" .. extension

	if ( filesystem.exists( hrvariant ) ) then
		return hrvariant
	end
end

function image:setFilename( filename )
	if ( _G.graphics.getPixelScale() > 1 ) then
		local variant = getHighResolutionVariant( filename )
		if ( variant ) then
			filename = variant
		end
	end

	self.filename = filename
end

function image:setWrap( horiz, vert )
	local image = self:getDrawable()
	image:setWrap( horiz, vert )
end

function image:__tostring()
	local t = getmetatable( self )
	setmetatable( self, {} )
	local s = string.gsub( tostring( self ), "table", "image" )
	setmetatable( self, t )
	return s
end
