--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Profiling interface
--
--==========================================================================--

require( "love.timer" )

local ipairs = ipairs
local love   = love
local print  = print
local string = string
local table  = table
local _G     = _G

module( "profile" )

_stack  = _stack  or {}
_parent = _parent or _stack

local function getChildren()
	-- `children` == `_stack` or budget.
	local children = _stack
	if ( _parent ~= _stack ) then
		_parent.children = _parent.children or {}
		children = _parent.children
	end
	return children
end

local function getBudget( children, name )
	for _, budget in ipairs( children ) do
		if ( budget.name == name ) then
			return budget
		end
	end
end

function push( name )
	local children = getChildren()
	local budget   = getBudget( children, name )
	if ( budget == nil ) then
		budget = { name = name, parent = _parent }
		table.insert( children, budget )
	end

	_parent = budget
	budget.startTime = love.timer.getTime()
end

function pop( name )
	_parent.endTime  = love.timer.getTime()
	_parent.duration = _parent.endTime - _parent.startTime
	_parent          = _parent.parent

	if ( _parent == nil ) then
		_parent = _stack
	end
	-- print( name .. " took " .. string.format( "%.3fms", 1000 * duration ) )
end
