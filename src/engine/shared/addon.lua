--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Addon interface
--
--============================================================================--

local filesystem = filesystem
local string     = string
local table      = table
local ipairs     = ipairs
local print      = print
local require    = require
local hook       = hook

module( "addon" )

local addons = {}

function initialize()
	local addons = filesystem.getDirectoryItems( "addons" )
	local v
	for i = #addons, -1, 1 do
		v = addons[ i ]
		if ( string.fileextension( v ) ~= "zip" or
		     not filesystem.isDirectory( v ) ) then
			table.remove( addons, i )
		end
	end

	for _, addon in ipairs( addons ) do
		mount( addon )
	end
end

function getAddons()
	return addons
end

function load( arg )
end

function unload()
end

function mount( addon )
	if ( filesystem.mount( "addons/" .. addon, "" ) ) then
		table.insert( addons, addon )
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

	if ( filesystem.unmount( "addons/" .. addon ) ) then
		hook.call( "shared", "onAddonUnmounted", addon )
		unrequire( "addons." .. addon )
		print( "Unmounted \"" .. addon .. "\"!" )
		return true
	end

	print( "Failed to unmount \"" .. addon .. "\"!" )
	return false
end
