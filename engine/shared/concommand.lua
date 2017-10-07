--=========== Copyright © 2017, Planimeter, All rights reserved. ===========--
--
-- Purpose: Concommand class
--
--==========================================================================--

class( "concommand" )

concommand._concommands = concommand._concommands or {}

local sv_cheats = convar( "sv_cheats", 0, nil, nil, "Allow cheats on server",
                          nil, { "notify" } )

function concommand.dispatch( player, name, argString, argTable )
	local concommand = concommand.getConcommand( name )
	if ( concommand == nil ) then
		return false
	end

	local flags = concommand:getFlags()
	if ( flags ) then
		local cheat = table.hasvalue( flags, "cheat" )
		if ( cheat and not sv_cheats:getBoolean() ) then
			return true
		end
	end

	if ( _CLIENT ) then
		if ( flags ) then
			local game = table.hasvalue( flags, "game" )
			if ( game and not engine.client.isInGame() ) then
				return true
			end
		end

		concommand:callback( player, name, argString, argTable )
	else
		concommand:callback( player, name, argString, argTable )
	end

	if ( flags ) then
		local networked = table.hasvalue( flags, "network" )
		if ( _CLIENT and networked ) then
			local payload = payload( "concommand" )
			payload:set( "name", name )
			payload:set( "argString", argString )
			engine.client.network.sendToServer( payload )
		end
	end

	return true
end

if ( _CLIENT ) then
	function concommand.run( name )
		local command = string.match( name, "^([^%s]+)" )
		if ( command == nil ) then
			return
		end

		local _, endPos = string.find( name, command, 1, true )
		local argString = string.trim( string.utf8sub( name, endPos + 1 ) )
		local argTable  = string.parseargs( argString )
		if ( concommand.getConcommand( command ) ) then
			concommand.dispatch( localplayer, command, argString, argTable )
		end
	end
end

function concommand.getConcommand( name )
	return concommand._concommands[ name ]
end

function concommand:concommand( name, helpString, callback, flags, autocomplete )
	self.name         = name
	self.helpString   = helpString
	self.callback     = callback
	self.flags        = flags
	self.autocomplete = autocomplete
	concommand._concommands[ name ] = self
end

function concommand:callback( player, command, argString, argTable )
end

function concommand:getAutocomplete()
	return self.autocomplete
end

function concommand:getCallback()
	return self.callback
end

function concommand:getFlags()
	return self.flags
end

function concommand:getHelpString()
	return self.helpString
end

function concommand:getName()
	return self.name
end

function concommand:remove()
	concommand._concommands[ self:getName() ] = nil
end

function concommand:setAutocomplete( autocomplete )
	self.autocomplete = autocomplete
end

function concommand:setCallback( callback )
	self.callback = callback
end

function concommand:setFlags( flags )
	self.flags = flags
end

function concommand:setHelpString( helpString )
	self.helpString = helpString
end

function concommand:__tostring()
	return "concommand: \"" .. self.name .. "\""
end
