--========= Copyright © 2013-2014, Planimeter, All rights reserved. ==========--
--
-- Purpose: Filesystem interface
--
--============================================================================--

local filesystem = love.filesystem
local pairs		 = pairs
-- local print	 = print
-- BUGBUG: Caching require causes filesystem changes to fail to be detected
-- more than once.
-- local require = require
local string	 = string
local table		 = table

-- BUGBUG: We force package.seeall here to allow constant access to
-- package.watched; storing the watched key causes access issues and we never
-- end up seeing what files have been modified.
module( "filesystem", package.seeall )

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

function lines( filename )
	return filesystem.lines( filename )
end

function read( name, size )
	return filesystem.read( name, size )
end

function remove( name )
	return filesystem.remove( name )
end

local library  = nil
local filename = nil
local modtime  = nil
local errormsg = nil

function update( dt )
	for i = #package.watched, 1, -1 do
		library	 = package.watched[ i ]
		filename = string.gsub( library.name, "%.", "/" ) .. ".lua"

		if ( not filesystem.exists( filename ) ) then
			filename = string.gsub( library.name, "%.", "/" ) .. "/init.lua"
		end

		modtime, errormsg = filesystem.getLastModified( filename )
		if ( errormsg == nil and modtime ~= library.modtime ) then
			package.loaded[ library.name ] = nil
			table.remove( package.watched, i )
			print( "Reloading " .. library.name .. "..." )
			local status, err = pcall( require, library.name )
			if ( status == false ) then
				print( err )
				table.insert( package.watched, {
					name	= library.name,
					modtime = filesystem.getLastModified( filename )
				} )
			end
		end
	end
end

function write( name, data, size )
	return filesystem.write( name, data, size )
end
