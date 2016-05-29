--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Require reimplementation
--
--============================================================================--

require( "engine.shared.filesystem" )

local error        = error
local filesystem   = filesystem
local ipairs       = ipairs
local pairs        = pairs
local pcall        = pcall
-- local print     = print
local string       = string
local table        = table
local _require     = require

package.watched    = package.watched or {}

local filename     = nil
local lastModified = nil
local errormsg     = nil

function package.update( dt )
	for modname, modtime in pairs( package.watched ) do
		filename = string.gsub( modname, "%.", "/" ) .. ".lua"
		if ( not filesystem.exists( filename ) ) then
			filename = string.gsub( modname, "%.", "/" ) .. "/init.lua"
		end

		lastModified, errormsg = filesystem.getLastModified( filename )
		if ( errormsg == nil and lastModified ~= modtime ) then
			package.loaded[ modname ]  = nil
			package.watched[ modname ] = nil
			print( "Reloading " .. modname .. "..." )
			local status, err = pcall( require, modname )
			if ( status == false ) then
				print( err )
				lastModified, errormsg = filesystem.getLastModified( filename )
				package.watched[ modname ] = lastModified
			else
				if ( game ) then
					game.call( "shared", "onReloadScript", modname )
				else
					require( "engine.shared.hook" )
					hook.call( "shared", "onReloadScript", modname )
				end
			end
		end
	end
end

function require( modname )
	if ( package.watched[ modname ] ) then
		return _require( modname )
	end

	local status, ret = pcall( _require, modname )
	if ( status ~= false ) then
		local filename = string.gsub( modname, "%.", "/" ) .. ".lua"
		if ( not filesystem.exists( filename ) ) then
			filename = string.gsub( modname, "%.", "/" ) .. "/init.lua"
		end

		package.watched[ modname ] = filesystem.getLastModified( filename )
		-- print( "Loading " .. modname .. "..." )
	else
		error( ret, 2 )
	end

	return ret
end

function unrequire( modname )
	if ( not package.watched[ modname ] ) then
		return
	end

	package.loaded[ modname ]  = nil
	package.watched[ modname ] = nil
	print( "Unloading " .. modname .. "..." )
end
