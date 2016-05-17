--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Filesystem interface
--
--============================================================================--

-- local _CLIENT = _CLIENT

local filesystem = love.filesystem
local package    = package
local _G         = _G

module( "filesystem" )

function createDirectory( name )
	return filesystem.createDirectory( name )
end

function exists( filename )
	return filesystem.exists( filename )
end

function getDirectoryItems( dir, callback )
	return filesystem.getDirectoryItems( dir, callback )
end

function getLastModified( filename )
	return filesystem.getLastModified( filename )
end

function isDirectory( filename )
	return filesystem.isDirectory( filename )
end

function lines( filename )
	return filesystem.lines( filename )
end

function mount( archive, mountpoint, appendToPath )
	return filesystem.mount( archive, mountpoint, appendToPath )
end

function newFileData( ... )
	return filesystem.newFileData( ... )
end

function read( name, size )
	return filesystem.read( name, size )
end

function remove( name )
	return filesystem.remove( name )
end

function update( dt )
	package.update( dt )

	if ( not _G._CLIENT ) then
		return
	end

	if ( _G.image ) then
		_G.image.update( dt )
	end

	if ( _G.sound ) then
		_G.sound.update( dt )
	end
end

function write( name, data, size )
	return filesystem.write( name, data, size )
end
