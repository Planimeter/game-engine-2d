--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Hook interface
--
--============================================================================--

local pairs = pairs
local pcall = pcall
local print = print
local table = table

module( "hook" )

_hooks        = _hooks        or {}
_hooks.client = _hooks.client or {}
_hooks.server = _hooks.server or {}
_hooks.shared = _hooks.shared or {}

function call( universe, event, ... )
	local eventHooks = _hooks[ universe ][ event ]
	if ( not eventHooks ) then
		return
	end

	for name, func in pairs( eventHooks ) do
		local v = { pcall( func, ... ) }
		if ( v[ 1 ] ) then
			if ( #v > 1 ) then
				table.remove( v, 1 )
				return unpack( v )
			end
		else
			print( "[hook \"" .. name .. "\" (" .. event .. ")]: " .. v[ 2 ] )
			remove( universe, event, name )
		end
	end
end

function set( universe, func, event, name )
	universe = universe or "shared"
	_hooks[ universe ][ event ] = _hooks[ universe ][ event ] or {}
	_hooks[ universe ][ event ][ name ] = func
end

function remove( universe, event, name )
	universe = universe or "shared"
	local eventHooks = _hooks[ universe ][ event ]
	if ( eventHooks and eventHooks[ name ] ) then
		eventHooks[ name ] = nil
		if ( table.len( eventHooks ) == 0 ) then
			_hooks[ universe ][ event ] = nil
		end
	end
end
