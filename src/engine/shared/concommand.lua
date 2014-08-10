--========= Copyright © 2013-2014, Planimeter, All rights reserved. ==========--
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
		return true
	else
		return false
	end
end

function concommand.getConcommand( name )
	return concommand.concommands[ name ]
end

function concommand:concommand( name, helpString, callback )
	self.name		= name
	self.helpString = helpString
	self.callback	= callback
	concommand.concommands[ name ] = self
end

function concommand:callback( player, command, argString, argTable )
end

function concommand:getCallback()
	return self.callback
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

function concommand:setHelpString( helpString )
	self.helpString = helpString
end

function concommand:__tostring()
	return "concommand: \"" .. self.name .. "\""
end
