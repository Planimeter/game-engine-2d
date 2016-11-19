-------------------------------------------------------------------------------
-- Lua with Classes
-- lclass
-- Author: Andrew McWatters
-------------------------------------------------------------------------------
local setmetatable = setmetatable
local type = type
local error = error
local pcall = pcall
local unpack = unpack
local rawget = rawget
local getfenv = getfenv
local ipairs = ipairs

-------------------------------------------------------------------------------
-- new()
-- Purpose: Creates a new object
-- Input: metatable
-- Output: object
-------------------------------------------------------------------------------
local function new( metatable )
	local object = {}
	setmetatable( object, metatable )
	return object
end

-------------------------------------------------------------------------------
-- eventnames
-- Purpose: Provide a list of all inheritable internal event names
-------------------------------------------------------------------------------
local eventnames = {
	"__add", "__sub", "__mul", "__div", "__mod",
	"__pow", "__unm", "__len", "__lt", "__le",
	"__concat", "__call",
	"__tostring"
}

-------------------------------------------------------------------------------
-- metamethod()
-- Purpose: Creates a filler metamethod for metamethod inheritance
-- Input: class - Class metatable
--        eventname - Event name
-- Output: function
-------------------------------------------------------------------------------
local function metamethod( class, eventname )
	return function( ... )
		local event = nil
		local base = getbaseclass( class )
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
-- getbaseclass()
-- Purpose: Get a base class
-- Input: class - Class metatable
-- Output: class
-------------------------------------------------------------------------------
local function getbaseclass( class )
	local name = class.__base
	return package.loaded[ name ]
end

_G.getbaseclass = getbaseclass

-------------------------------------------------------------------------------
-- package.class
-- Purpose: Turns a module into a class
-- Input: module - Module table
-------------------------------------------------------------------------------
function package.class( module )
	module.__index = module
	module.__type = module._NAME
	-- Create a shortcut to name()
	setmetatable( module, {
		__call = function( self, ... )
			-- Create a new instance of this object
			local object = new( self )
			-- Call its constructor (function name:name( ... ) ... end) if it
			-- exists
			local v = rawget( self, self._NAME )
			if ( v ~= nil ) then
				local type = type( v )
				if ( type ~= "function" ) then
					error( "attempt to call constructor '" .. name .. "' " ..
					       "(a " .. type .. " value)", 2 )
				end
				v( object, ... )
			end
			-- Return the new instance
			return object
		end
	} )
end

-------------------------------------------------------------------------------
-- package.inherit
-- Purpose: Sets a base class
-- Input: base - Class name
-------------------------------------------------------------------------------
function package.inherit( base )
	return function( module )
		-- Set our base class
		module.__base = base
		-- Overwrite our existing __index value with a metamethod which checks
		-- our members, metatable, and base class, in that order, a la behavior
		-- via the Lua 5.1 manual's illustrative code for indexing access
		module.__index = function( table, key )
			local module = package.loaded[ module._NAME ]
			local baseclass = getbaseclass( module )
			if ( baseclass == nil ) then
				error( "attempt to index class '" .. module.__base .. "' " ..
				       "(a nil value)", 2 )
			end
			local h = rawget( getbaseclass( module ), "__index" )
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
