--=========== Copyright © 2017, Planimeter, All rights reserved. =============--
--
-- Purpose: Extends the package library
--
--============================================================================--

require( "package" )

if ( not rawrequire ) then
	rawrequire = require
end

local function getModuleFilename( modname )
	local module = string.gsub( modname, "%.", "/" )
	for path in string.gmatch( package.path, "(.-);" ) do
		path = string.gsub( path, "%./", "" )
		local filename = string.gsub( path, "?", module )
		if ( love.filesystem.exists( filename ) ) then
			return filename
		end
	end
end

function require( modname )
	if ( package.watched[ modname ] ) then
		return rawrequire( modname )
	end

	local status, ret = pcall( rawrequire, modname )
	if ( not status ) then
		error( ret, 2 )
	end

	local filename = getModuleFilename( modname )
	if ( filename ) then
		package.watched[ modname ] = love.filesystem.getLastModified( filename )
	end
	return ret
end

local function unload( modname )
	package.loaded[ modname ] = nil
	package.watched[ modname ] = nil
end

function unrequire( modname )
	unload( modname )
	print( "Unloading " .. modname .. "..." )
end

package.watched = package.watched or {}

local function reload( modname, filename )
	unload( modname )
	print( "Updating " .. modname .. "..." )

	local status, err = pcall( require, modname )
	if ( status ) then return end

	print( err )

	local modtime, errormsg = love.filesystem.getLastModified( filename )
	package.watched[ modname ] = modtime
end

function package.update( dt )
	for k, v in pairs( package.watched ) do
		local filename = getModuleFilename( k )
		local modtime, errormsg = love.filesystem.getLastModified( filename )
		if ( not errormsg and modtime ~= v ) then
			reload( k, filename )
		end
	end
end
