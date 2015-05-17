--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Concommand class
--
--============================================================================--

-- These values are preserved during real-time scripting.
local concommands = concommand and concommand.concommands or {}

class( "concommand" )

concommand.concommands = concommands

function concommand.dispatch( player, name, argString, argTable )
	local concommand = concommand.getConcommand( name )
	if ( concommand ) then
		concommand:callback( player, name, argString, argTable )

		local flags     = concommand:getFlags()
		local networked = table.hasvalue( flags, "network" )
		if ( _CLIENT and networked ) then
			local payload = payload( "concommand" )
			payload:set( "name", name )
			payload:set( "argString", argString )
			networkclient.sendToServer( payload )
		end

		return true
	else
		return false
	end
end

function concommand.getConcommand( name )
	return concommand.concommands[ name ]
end

function concommand:concommand( name, helpString, callback, flags )
	self.name       = name
	self.helpString = helpString
	self.callback   = callback
	self.flags      = flags or {}
	concommand.concommands[ name ] = self
end

function concommand:callback( player, command, argString, argTable )
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
	concommand.concommands[ self:getName() ] = nil
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
