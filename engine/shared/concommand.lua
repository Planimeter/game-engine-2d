--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Concommand class
--
--============================================================================--

local convar  = convar
local engine  = engine
local table   = table
local _CLIENT = _CLIENT

module( "concommand", package.class )

concommands = concommands or {}

local sv_cheats = convar( "sv_cheats", 0, nil, nil, "Allow cheats on server",
                          nil, { "notify" } )

function dispatch( player, name, argString, argTable )
	local concommand = getConcommand( name )
	if ( not concommand ) then
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
			networkclient.sendToServer( payload )
		end
	end

	return true
end

if ( _CLIENT ) then
	function run( name )
		local command = string.match( name, "^([^%s]+)" )
		if ( not command ) then
			return
		end

		local _, endPos = string.find( name, command, 1, true )
		local argString = string.trim( string.utf8sub( name, endPos + 1 ) )
		local argTable  = string.parseargs( argString )
		if ( getConcommand( command ) ) then
			dispatch( localplayer, command, argString, argTable )
		end
	end
end

function getConcommand( name )
	return concommands[ name ]
end

function _M:concommand( name, helpString, callback, flags, autocomplete )
	self.name         = name
	self.helpString   = helpString
	self.callback     = callback
	self.flags        = flags
	self.autocomplete = autocomplete
	concommands[ name ] = self
end

function _M:callback( player, command, argString, argTable )
end

function _M:getAutocomplete()
	return self.autocomplete
end

function _M:getCallback()
	return self.callback
end

function _M:getFlags()
	return self.flags
end

function _M:getHelpString()
	return self.helpString
end

function _M:getName()
	return self.name
end

function _M:remove()
	concommands[ self:getName() ] = nil
end

function _M:setAutocomplete( autocomplete )
	self.autocomplete = autocomplete
end

function _M:setCallback( callback )
	self.callback = callback
end

function _M:setFlags( flags )
	self.flags = flags
end

function _M:setHelpString( helpString )
	self.helpString = helpString
end

function _M:__tostring()
	return "concommand: \"" .. self.name .. "\""
end
