--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Addon interface
--
--============================================================================--

local filesystem = filesystem
local string     = string
local table      = table
local ipairs     = ipairs
local print      = print

module( "addon" )

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
		if ( filesystem.mount( "addons/" .. addon, "" ) ) then
			print( "Mounted \"" .. addon .. "\"!" )
		else
			print( "Failed to mount \"" .. addon .. "\"!" )
		end
	end
end
