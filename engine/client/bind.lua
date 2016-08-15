--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Bind interface
--
--============================================================================--

class( "bind" )

local binds = {}

function bind.getBinds()
	return binds
end

function bind.getBind( key )
	return binds[ key ]
end

function bind.getKeyForBind( concommand )
	for key, bind in pairs( bind.getBinds() ) do
		if ( bind == concommand ) then
			return key
		end
	end
end

function bind.setBind( key, concommand )
	binds[ key ] = concommand
end

concommand( "bind", "Binds a key",
	function( _, _, _, _, argT )
		local key        = argT[ 1 ]
		local concommand = argT[ 2 ]
		if ( key == nil ) then
			print( "bind <key> <console command>" )
			return
		end

		if ( concommand ) then
			bind.setBind( key, concommand )
		else
			print( bind.getBind( key ) )
		end
	end
)

function bind.readBinds()
	local config = "cfg/binds.cfg"
	if ( not love.filesystem.exists( config ) ) then
		config = "cfg/binds_default.cfg"
		if ( love.filesystem.exists( config ) ) then
			love.filesystem.write( "cfg/binds.cfg", love.filesystem.read( config ) )
		else
			return
		end
	end

	for line in love.filesystem.lines( config ) do
		for k, v in string.gmatch( line, "(.+)%s(.+)" ) do
			bind.setBind( string.trim( k ), string.trim( v ) )
		end
	end
end

function bind.readDefaultBinds()
	local config = "cfg/binds_default.cfg"
	if ( not love.filesystem.exists( config ) ) then
		return
	end

	local binds = {}
	for line in love.filesystem.lines( config ) do
		for k, v in string.gmatch( line, "(.+)%s(.+)" ) do
			bind.setBind( string.trim( k ), string.trim( v ) )
		end
	end
	return binds
end

function bind.saveBinds()
	local config = {}
	for k, v in pairs( bind.getBinds() ) do
		table.insert( config, k .. " " .. v )
	end
	table.insert( config, "" )
	config = table.concat( config, "\r\n" )

	love.filesystem.createDirectory( "cfg" )

	if ( love.filesystem.write( "cfg/binds.cfg", config ) ) then
		print( "Saved binds." )
	else
		print( "Failed to save binds!" )
	end
end

function bind.keypressed( key, scancode, isrepeat )
	local bind = bind.getBind( key )
	if ( bind and not concommand.dispatch( localplayer, bind ) ) then
		print( "'" .. bind .. "' is not recognized as a command." )
	end
end

function bind.keyreleased( key, scancode )
	local bind = bind.getBind( key )
	if ( not bind ) then
		return
	end

	local isButtonCommand = string.find( bind, "+" ) == 1
	if ( isButtonCommand ) then
		bind = string.gsub( bind, "%+", "-" )
		if ( not concommand.dispatch( localplayer, bind ) ) then
			print( "'" .. bind .. "' is not recognized as a command." )
		end
	end
end

function bind.mousepressed( x, y, button, istouch )
	bind.keypressed( button, nil, false )
end

function bind.mousereleased( x, y, button, istouch )
	bind.keyreleased( button )
end
