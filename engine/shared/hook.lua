--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Hook interface
--
--============================================================================--

local pairs  = pairs
local pcall  = pcall
local select = select
local unpack = unpack
local table  = table
local print  = print

module( "hook" )

local hooks  = {}
hooks.client = {}
hooks.server = {}
hooks.shared = {}

function call( universe, event, ... )
	local eventHooks = hooks[ universe ][ event ]
	if ( not eventHooks ) then
		return
	end

	local values

	for name, func in pairs( eventHooks ) do
		values = { pcall( func, ... ) }
		if ( values[ 1 ] ) then
			if ( #values > 1 ) then
				table.remove( values, 1 )
				return unpack( values )
			end
		else
			print( "[hook \"" .. name .. "\" (" .. event .. ")]: " .. values[ 2 ] )
			remove( universe, event, name )
		end
	end
end

function set( universe, func, event, name )
	universe = universe or "shared"
	hooks[ universe ][ event ] = hooks[ universe ][ event ] or {}
	hooks[ universe ][ event ][ name ] = func
end

function remove( universe, event, name )
	universe = universe or "shared"
	local eventHooks = hooks[ universe ][ event ]
	if ( eventHooks and eventHooks[ name ] ) then
		eventHooks[ name ] = nil
		if ( table.len( eventHooks ) == 0 ) then
			hooks[ universe ][ event ] = nil
		end
	end
end
