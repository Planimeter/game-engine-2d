--========= Copyright © 2013-2014, Planimeter, All rights reserved. ==========--
--
-- Purpose: Require reimplementation
--
--============================================================================--

require( "engine.shared.filesystem" )

local error		 = error
local filesystem = filesystem
local ipairs	 = ipairs
local pcall		 = pcall
local string	 = string
local table		 = table
local _require	 = require

package.watched	 = {}

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
			name	= modname,
			modtime = filesystem.getLastModified( filename )
		} )
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
