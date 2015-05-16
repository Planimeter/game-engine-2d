--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Require reimplementation
--
--============================================================================--

require( "engine.shared.filesystem" )

local error      = error
local filesystem = filesystem
local hook       = hook
local ipairs     = ipairs
local pairs      = pairs
local pcall      = pcall
local print      = print
local string     = string
local table      = table
local _require   = require

package.watched  = package.watched or {}

local library  = nil
local filename = nil
local modtime  = nil
local errormsg = nil

function package.update( dt )
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
					name    = library.name,
					modtime = filesystem.getLastModified( filename )
				} )
			else
				if ( game ) then
					game.call( "shared", "onReload", library.name )
				else
					require( "engine.shared.hook" )
					hook.call( "shared", "onReload", library.name )
				end
			end
		end
	end
end

function require( modname )
	for i, v in ipairs( package.watched ) do
		if ( v.name == modname ) then
			return _require( modname )
		end
	end

	local status, ret = pcall( _require, modname )
	if ( status ~= false ) then
		local filename = string.gsub( modname, "%.", "/" ) .. ".lua"
		if ( not filesystem.exists( filename ) ) then
			filename = string.gsub( modname, "%.", "/" ) .. "/init.lua"
		end

		table.insert( package.watched, {
			name    = modname,
			modtime = filesystem.getLastModified( filename )
		} )
		-- print( "Loading " .. modname .. "..." )
	else
		error( ret, 2 )
	end

	return ret
end

function unrequire( modname )
	for i = #package.watched, 1, -1 do
		local t = package.watched[ i ]
		if ( t.name == modname ) then
			package.loaded[ t.name ] = nil
			table.remove( package.watched, i )
			print( "Unloading " .. t.name .. "..." )
		end
	end
end
