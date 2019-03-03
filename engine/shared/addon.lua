--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Addon interface
--
--==========================================================================--

local hook    = hook
local love    = love
local print   = print
local require = require
local string  = string
local table   = table
local ipairs  = ipairs

module( "addon" )

function load( arg )
	local addons = love.filesystem.getDirectoryItems( "addons" )
	for i = #addons, -1, 1 do
		local v = addons[ i ]
		local info = love.filesystem.getInfo( v )
		local isDirectory = info and info.type == "directory" or false
		if ( string.fileextension( v ) ~= "zip" or not isDirectory ) then
			table.remove( addons, i )
		end
	end

	for _, v in ipairs( addons ) do
		mount( v )
	end
end

_addons = _addons or {}

function getAddons()
	return _addons
end

function mount( addon )
	if ( love.filesystem.mount( "addons/" .. addon, "" ) ) then
		table.insert( getAddons(), addon )
		print( "Mounted \"" .. addon .. "\"!" )
		require( "addons." .. addon )
		hook.call( "shared", "onAddonMounted", addon )
		return true
	end

	print( "Failed to mount \"" .. addon .. "\"!" )
	return false
end

function unmount( addon )
	local mounted = table.hasvalue( getAddons(), addon )
	if ( not mounted ) then
		print( "Addon \"" .. addon .. "\" is not mounted!" )
		return false
	end

	if ( love.filesystem.unmount( "addons/" .. addon ) ) then
		hook.call( "shared", "onAddonUnmounted", addon )
		unrequire( "addons." .. addon )
		print( "Unmounted \"" .. addon .. "\"!" )
		return true
	end

	print( "Failed to unmount \"" .. addon .. "\"!" )
	return false
end
