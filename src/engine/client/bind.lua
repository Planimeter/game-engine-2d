--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Bind interface
--
--============================================================================--

-- These values are preserved during real-time scripting.
local _binds = bind and bind.getBinds() or {}

local concommand = concommand
local filesystem = filesystem
local pairs      = pairs
local print      = print
local string     = string
local table      = table
local _G         = _G

module( "bind" )

local binds = _binds

function getBinds()
	return binds
end

function getBind( key )
	return binds[ key ]
end

function getKeyForBind( concommand )
	for key, bind in pairs( binds ) do
		if ( bind == concommand ) then
			return key
		end
	end
end

function setBind( key, concommand )
	binds[ key ] = concommand
end

function readBinds()
	local config = "cfg/binds.cfg"
	if ( not filesystem.exists( config ) ) then
		config = "cfg/binds_default.cfg"
		if ( filesystem.exists( config ) ) then
			filesystem.write( "cfg/binds.cfg", filesystem.read( config ) )
		else
			return
		end
	end

	for line in filesystem.lines( config ) do
		for k, v in string.gmatch( line, "(.+)%s(.+)" ) do
			binds[ string.trim( k ) ] = string.trim( v )
		end
	end
end

function readDefaultBinds()
	local config = "cfg/binds_default.cfg"
	if ( not filesystem.exists( config ) ) then
		return
	end

	local binds  = {}
	for line in filesystem.lines( config ) do
		for k, v in string.gmatch( line, "(.+)%s(.+)" ) do
			binds[ string.trim( k ) ] = string.trim( v )
		end
	end
	return binds
end

function saveBinds()
	local config = {}
	for k, v in pairs( binds ) do
		table.insert( config, k .. " " .. v )
	end
	table.insert( config, "" )
	config = table.concat( config, "\r\n" )

	filesystem.createDirectory( "cfg" )

	if ( filesystem.write( "cfg/binds.cfg", config ) ) then
		print( "Saved binds." )
	else
		print( "Failed to save binds!" )
	end
end

function keypressed( key, isrepeat )
	local bind = getBind( key )
	if ( bind and not concommand.dispatch( _G.localplayer, bind ) ) then
		print( "'" .. bind .. "' is not recognized as a command." )
	end
end

function keyreleased( key )
	local bind = getBind( key )
	if ( not bind ) then
		return
	end

	local isButtonCommand = string.sub( bind, 1, 1 ) == "+"
	if ( isButtonCommand ) then
		bind = string.gsub( bind, "%+", "-" )
		if ( not concommand.dispatch( _G.localplayer, bind ) ) then
			print( "'" .. bind .. "' is not recognized as a command." )
		end
	end
end

function mousepressed( x, y, button )
	keypressed( button, false )
end

function mousereleased( x, y, button )
	keyreleased( button )
end
