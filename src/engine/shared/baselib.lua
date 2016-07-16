--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Extends the base library
--
--============================================================================--

require( "engine.shared.concommand" )

if ( not rawdofile ) then
	rawdofile = dofile

	function dofile( filename )
		local f = assert( filesystem.load( filename ) )
		return f()
	end
end

function mutator( class, member, key )
	class[ "set" .. string.capitalize( member ) ] = function( self, value )
		self[ key or member ] = value
	end

	accessor( class, member, key )
end

function accessor( class, member, key )
	class[ "get" .. string.capitalize( member ) ] = function( self )
		return self[ key or member ]
	end
end

if ( not rawprint and not rawtype ) then
	rawprint           = print
	rawtype            = type

	local _print       = print
	local rawtype      = rawtype
	local tonumber     = tonumber
	local assert       = assert
	local getmetatable = getmetatable
	local rawget       = rawget

	function print( ... )
		_print( ... )

		if ( ( _CLIENT or _INTERACTIVE ) and g_Console ) then
			g_Console.print( ... )
		end
	end

	function type( object )
		local mt = getmetatable( object )
		if ( mt ~= nil and rawget( mt, "__type" ) ~= nil ) then
			return rawget( mt, "__type" )
		end

		return rawtype( object )
	end
end

function typeof( object, class )
	if ( type( object ) == class ) then
		return true
	end

	if ( rawtype( object ) == "table" ) then
		local base = getbaseclass( object )
		while ( base ~= nil ) do
			if ( base.__type == class ) then
				return true
			end

			base = getbaseclass( base )
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

		local success, ret = pcall( filesystem.load, argString )
		if ( success ) then
			success, ret = pcall( ret )
			if ( not success ) then
				print( ret )
			end
		else
			print( ret )
		end
	end,

	nil,

	function( argS )
		local autocomplete = {}
		local dir = string.stripfilename( argS )
		local files = filesystem.getDirectoryItems( dir )
		for _, v in ipairs( files ) do
			if ( filesystem.isDirectory( dir .. v ) or
			     string.fileextension( v ) == "lua" ) then
				local filename = ( dir ~= "" and dir or "" ) .. v
				local cmd      = "lua_dofile " .. filename
				if ( string.find( cmd, "lua_dofile " .. argS, 1, true ) ) then
					table.insert( autocomplete, cmd )
				end
			end
		end

		table.sort( autocomplete )

		return autocomplete
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
