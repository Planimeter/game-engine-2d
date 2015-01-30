--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Extends the base library
--
--============================================================================--

require( "engine.shared.concommand" )

rawtype			   = type
rawprint		   = print

local _print	   = print
local rawtype	   = rawtype
local tonumber	   = tonumber
local assert	   = assert
local getmetatable = getmetatable
local rawget	   = rawget

function print( ... )
	_print( ... )

	if ( ( _CLIENT or _INTERACTIVE ) and g_Console ) then
		g_Console.print( ... )
	end
end

-- UNDONE: Andrew; We might come back and use these for something eventually.
-- If you need an explicit conversion to a boolean, I strongly encourage you to
-- find a solution on a case-by-case basis.
-- local t = nil

-- function toboolean( v )
-- 	t = rawtype( v )
-- 	if ( t == "nil" ) then
-- 		return false
-- 	elseif ( t == "boolean" ) then
-- 		return v
-- 	elseif ( t == "number" ) then
-- 		return v ~= 0
-- 	elseif ( t == "string" ) then
-- 		if ( v == "nil" ) then
-- 			return false
-- 		elseif ( v == "false" ) then
-- 			return false
-- 		elseif ( v == "true" ) then
-- 			return true
-- 		elseif ( tonumber( v ) ) then
-- 			return tonumber( v ) ~= 0
-- 		else
-- 			return true
-- 		end
-- 	elseif ( t == "table" or
-- 			 t == "function" or
-- 			 t == "userdata" or
-- 			 t == "thread"	 or
-- 			 t == "proto"	 or
-- 			 t == "upval" ) then
-- 		return true
-- 	end
-- 	assert( false )
-- end

-- -- Thanks, Foxtrot200!
-- function toboolean( v )
-- 	return v and ( v ~= "nil" and v ~= "false" and tonumber( v ) ~= 0 )
-- end

function type( object )
	local mt = getmetatable( object )
	if ( mt ~= nil and rawget( mt, "__type" ) ~= nil ) then
		return rawget( mt, "__type" )
	end

	return rawtype( object )
end

local base = nil

function typeof( object, class )
	if ( type( object ) == class ) then
		return true
	end

	if ( rawtype( object ) == "table" and object.__base ) then
		base = object.__base
		while ( base ~= nil ) do
			if ( base.__type == class ) then
				return true
			end

			base = base.__base
		end
	end

	return rawtype( object ) == class
end

function typerror( narg, tname, value )
	local info = debug.getinfo( 2, "n" )
	error( "bad argument #" .. narg .. " " ..
		   "to '" .. info.name ..
		   "' (" .. tname .. " expected, " ..
		   "got " .. type( value ) .. ")", 3 )
end

concommand( "lua_dofile", "Loads and runs the given file",
	function( self, player, command, argString, argTable )
		if ( argTable[ 1 ] == nil ) then
			print( "lua_dofile <filename>" )
			return
		end

		local f, err = loadfile( argString )
		if ( f ) then
			local success, err = pcall( f )
			if ( not success ) then
				print( err )
			end
		else
			print( err )
		end
	end
)

concommand( "lua_dostring", "Loads and runs the given string",
	function( self, player, command, argString, argTable )
		if ( argTable[ 1 ] == nil ) then
			print( "lua_dostring <string>" )
			return
		end

		local f, err = loadstring( argString )
		if ( f ) then
			local success, err = pcall( f )
			if ( not success ) then
				print( err )
			end
		else
			print( err )
		end
	end
)
