-------------------------------------------------------------------------------
-- Lua with Classes
-- lclass
-- Author: Andrew McWatters
-------------------------------------------------------------------------------
local setmetatable = setmetatable
local package = package
local type = type
local error = error
local pcall = pcall
local unpack = unpack
local newproxy = newproxy
local string = string
local rawget = rawget
local ipairs = ipairs
local module = module
local _G = _G
local _R = debug.getregistry()

-------------------------------------------------------------------------------
-- new()
-- Purpose: Creates an object
-- Input: metatable
-- Output: object
-------------------------------------------------------------------------------
local function new( metatable )
	local object = {}
	setmetatable( object, metatable )
	return object
end

-------------------------------------------------------------------------------
-- getbaseclass()
-- Purpose: Gets a base class
-- Input: metatable
-- Output: metatable
-------------------------------------------------------------------------------
local function getbaseclass( metatable )
	local base = metatable.__base
	return package.loaded[ base ]
end

_G.getbaseclass = getbaseclass

-------------------------------------------------------------------------------
-- eventnames
-- Purpose: Provides a list of all inheritable internal event names
-------------------------------------------------------------------------------
local eventnames = {
	"__add", "__sub", "__mul", "__div", "__mod",
	"__pow", "__unm", "__len", "__lt", "__le",
	"__concat", "__call",
	"__tostring"
}

-------------------------------------------------------------------------------
-- metamethod()
-- Purpose: Creates a placeholder metamethod for metamethod inheritance
-- Input: metatable
--        eventname
-- Output: function
-------------------------------------------------------------------------------
local function metamethod( metatable, eventname )
	return function( ... )
		local event = nil
		local base = getbaseclass( metatable )
		while ( base ~= nil ) do
			if ( base[ eventname ] ) then
				event = base[ eventname ]
				break
			end
			base = getbaseclass( base )
		end
		local type = type( event )
		if ( type ~= "function" ) then
			error( "attempt to call metamethod '" .. eventname .. "' " ..
			       "(a " .. type .. " value)", 2 )
		end
		local returns = { pcall( event, ... ) }
		if ( returns[ 1 ] ~= true ) then
			error( returns[ 2 ], 2 )
		else
			return unpack( returns, 2 )
		end
	end
end

-------------------------------------------------------------------------------
-- setproxy()
-- Purpose: Sets a proxy for __gc
-- Input: object
-------------------------------------------------------------------------------
local function setproxy( object )
	local __newproxy = newproxy( true )
	local metatable = getmetatable( __newproxy )
	metatable.__gc = function()
		local metatable = getmetatable( object )
		metatable.__gc( object )
	end
	object.__newproxy = __newproxy
end

_G.setproxy = setproxy

-------------------------------------------------------------------------------
-- classinit
-- Purpose: Initializes a class
-- Input: module
-------------------------------------------------------------------------------
local function classinit( module )
	module.__index = module
	module.__type = string.gsub( module._NAME, module._PACKAGE, "" )
	module._M = nil
	module._NAME = nil
	module._PACKAGE = nil
	-- Create a shortcut to name()
	setmetatable( module, {
		__call = function( self, ... )
			-- Create an instance of this object
			local object = new( self )
			-- Call its constructor (function name:name( ... ) ... end) if it
			-- exists
			local constructor = rawget( self, self.__type )
			if ( constructor ~= nil ) then
				local type = type( constructor )
				if ( type ~= "function" ) then
					error( "attempt to call constructor '" .. name .. "' " ..
					       "(a " .. type .. " value)", 2 )
				end
				constructor( object, ... )
			end
			-- Return the instance
			return object
		end
	} )
end

-------------------------------------------------------------------------------
-- inherit
-- Purpose: Sets a base class
-- Input: base - Name of metatable
-------------------------------------------------------------------------------
local function inherit( base )
	return function( module )
		-- Set our base class
		module.__base = base
		-- Overwrite our existing __index value with a metamethod which checks
		-- our members, metatable, and base class, in that order, a la behavior
		-- via the Lua 5.1 manual's illustrative code for indexing access
		module.__index = function( table, key )
			local v = rawget( module, key )
			if ( v ~= nil ) then return v end
			local baseclass = getbaseclass( module )
			if ( baseclass == nil ) then
				error( "attempt to index base class '" .. base .. "' " ..
					   "(a nil value)", 2 )
			end
			local h = rawget( baseclass, "__index" )
			if ( h == nil ) then return nil end
			if ( type( h ) == "function" ) then
				return h( table, key )
			else
				return h[ key ]
			end
		end
		-- Create inheritable metamethods
		for _, event in ipairs( eventnames ) do
			module[ event ] = metamethod( module, event )
		end
	end
end

-------------------------------------------------------------------------------
-- class()
-- Purpose: Creates a class
-- Input: modname
-------------------------------------------------------------------------------
function class( modname )
	local function setmodule( modname )
		module( modname, classinit )
	end setmodule( modname )
	_R[ modname ] = package.loaded[ modname ]
	-- For syntactic sugar, return a function to set inheritance
	return function( base )
		local metatable = package.loaded[ modname ]
		inherit( base )( metatable )
	end
end
