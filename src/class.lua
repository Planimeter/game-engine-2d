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
-- Input: class - The class metatable
--		  eventname - The event name
-- Output: function
-------------------------------------------------------------------------------
local function metamethod( class, eventname )
	return function( ... )
		local event = class.__base[ eventname ]
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
-- classes
-- Purpose: Store classes for real-time class redefining
-------------------------------------------------------------------------------
local classes = {}

-------------------------------------------------------------------------------
-- class()
-- Purpose: Creates a new class
-- Input: name - Name of new class
-------------------------------------------------------------------------------
function class( name )
	classes[ name ] = {}
	classes[ name ].__index = classes[ name ]
	classes[ name ].__type = name
	-- Create a shortcut to name()
	setmetatable( classes[ name ], {
		__call = function( _, ... )
			-- Create a new instance of this object
			local object = new( classes[ name ] )
			-- Call its constructor (function name:name( ... ) ... end) if it
			-- exists
			local v = rawget( classes[ name ], name )
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
	-- Make the class available to the environment from which it was defined
	getfenv( 2 )[ name ] = classes[ name ]
	-- For syntactic sugar, return a function to set inheritance
	return function( base )
		-- Set our base class to the class definition in the function
		-- environment we called from
		if ( type( base ) == "string" ) then
			classes[ name ].__base = getfenv( 2 )[ base ]
		else
			-- Otherwise set the base class directly
			classes[ name ].__base = base
		end
		-- Overwrite our existing __index value with a metamethod which checks
		-- our members, metatable, and base class, in that order, a la behavior
		-- via the Lua 5.1 manual's illustrative code for indexing access
		classes[ name ].__index = function( table, key )
			local h
			if ( type( table ) == "table" ) then
				local v = rawget( table, key )
				if ( v ~= nil ) then return v end
				v = rawget( classes[ name ], key )
				if ( v ~= nil ) then return v end
				h = rawget( classes[ name ].__base, "__index" )
				if ( h == nil ) then return nil end
			end
			if ( type( h ) == "function" ) then
				return h( table, key )
			else
				return h[ key ]
			end
		end
		-- Create inheritable metamethods
		for _, event in ipairs( eventnames ) do
			classes[ name ][ event ] = metamethod( classes[ name ], event )
		end
	end
end
