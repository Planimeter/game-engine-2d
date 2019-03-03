--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: Extends the package library
--
--==========================================================================--

require( "package" )

if ( rawrequire == nil ) then
	rawrequire = require
end

local function getModuleFilename( modname )
	local module = string.gsub( modname, "%.", "/" )
	for _, paths in ipairs( {
		string.gmatch( package.path .. ";", "(.-);" ),
		string.gmatch( love.filesystem.getRequirePath() .. ";", "(.-);" )
	} ) do
		for path in paths do
			path = string.gsub( path, "%.[\\/]", "" )
			local filename = string.gsub( path, "?", module )
			if ( path ~= "" and
			     love.filesystem.getInfo( filename ) ~= nil ) then
				return filename
			end
		end
	end
end

function require( modname )
	if ( package.watched[ modname ] ) then
		return rawrequire( modname )
	end

	local status, ret = pcall( rawrequire, modname )
	if ( status == false ) then
		error( ret, 2 )
	end

	local filename = getModuleFilename( modname )
	if ( filename ) then
		local modtime = love.filesystem.getInfo( filename ).modtime
		package.watched[ modname ] = modtime
	else
		package.watched[ modname ] = -1
	end

	-- print( "Loaded " .. modname )
	return ret
end

local function unload( modname )
	package.loaded[ modname ] = nil
	package.watched[ modname ] = nil
end

function unrequire( modname )
	unload( modname )
	-- print( "Unloaded " .. modname )
end

package.watched = package.watched or {}

local function reload( modname, filename )
	unload( modname )
	print( "Updating " .. modname .. "..." )

	local status, err = pcall( require, modname )
	if ( status == true ) then
		if ( game ) then
			game.call( "shared", "onReloadScript", modname )
		else
			hook.call( "shared", "onReloadScript", modname )
		end

		return
	end

	print( err )

	local modtime = love.filesystem.getInfo( filename ).modtime
	package.watched[ modname ] = modtime
end

local function update( k, v )
	if ( v == -1 ) then
		return
	end

	local filename = getModuleFilename( k )
	if ( filename == nil ) then
		return
	end

	local modtime = love.filesystem.getInfo( filename ).modtime
	if ( modtime ~= v ) then
		reload( k, filename )
	end
end

function package.update( dt )
	for modname, modtime in pairs( package.watched ) do
		update( modname, modtime )
	end
end
