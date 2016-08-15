--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Require reimplementation
--
--============================================================================--

package.watched = package.watched or {}

if ( not rawrequire ) then
	rawrequire = require
end

local function getModuleFilename( modname )
	local path = string.gsub( modname, "%.", "/" )
	local filename = path .. ".lua"
	if ( not love.filesystem.exists( filename ) ) then
		filename = path .. "/init.lua"
	end
	return filename
end

function require( modname )
	if ( package.watched[ modname ] ) then
		return rawrequire( modname )
	end

	local status, ret = pcall( rawrequire, modname )
	if ( not status ) then error( ret, 2 ) end

	local filename = getModuleFilename( modname )
	package.watched[ modname ] = love.filesystem.getLastModified( filename )
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

local function update( modname, filename )
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
			update( k, filename )
		end
	end
end
