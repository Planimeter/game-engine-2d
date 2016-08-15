--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Addon interface
--
--============================================================================--

class( "addon" )

function addon.load( arg )
	local addons = love.filesystem.getDirectoryItems( "addons" )
	for i = #addons, -1, 1 do
		local v = addons[ i ]
		if ( string.fileextension( v ) ~= "zip" or
		     not love.filesystem.isDirectory( v ) ) then
			table.remove( addons, i )
		end
	end

	for _, v in ipairs( addons ) do
		addon.mount( v )
	end
end

local addons = {}

function addon.getAddons()
	return addons
end

function addon.mount( addon )
	if ( love.filesystem.mount( "addons/" .. addon, "" ) ) then
		table.insert( addon.getAddons(), addon )
		print( "Mounted \"" .. addon .. "\"!" )
		require( "addons." .. addon )
		hook.call( "shared", "onAddonMounted", addon )
		return true
	end

	print( "Failed to mount \"" .. addon .. "\"!" )
	return false
end

function addon.unmount( addon )
	local mounted = table.hasvalue( addon.getAddons(), addon )
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
