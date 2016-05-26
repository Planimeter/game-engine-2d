--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Convar class
--
--============================================================================--

-- These values are preserved during real-time scripting.
local config  = convar and convar.config  or {}
local convars = convar and convar.convars or {}

require( "class" )

class( "convar" )

convar.config  = config
convar.convars = convars

function convar.getConfig( name )
	return convar.config[ name ]
end

function convar.getConvar( name )
	return convar.convars[ name ]
end

function convar.setConvar( name, value )
	local convar = convar.getConvar( name )
	if ( convar ) then
		convar:setValue( value )
		return true
	else
		return false
	end
end

function convar.readConfig()
	if ( not filesystem.exists( "cfg/config.cfg" ) ) then
		return
	end

	for line in filesystem.lines( "cfg/config.cfg" ) do
		for k, v in string.gmatch( line, "(.+)%s(.+)" ) do
			convar.config[ k ] = v
		end
	end
end

function convar.saveConfig()
	local config = {}
	for k, v in pairs( convar.convars ) do
		table.insert( config, k .. " " .. tostring( v:getValue() ) )
	end
	table.insert( config, "" )
	config = table.concat( config, "\r\n" )

	filesystem.createDirectory( "cfg" )

	if ( filesystem.write( "cfg/config.cfg", config ) ) then
		print( "Saved configuration." )
	else
		print( "Failed to save configuration!" )
	end
end

function convar:convar( name, default, min, max, helpString, onValueChange, flags )
	self.name              = name
	self.default           = default
	self.value             = convar.config[ name ] or default
	self.min               = min
	self.max               = max
	self.helpString        = helpString
	self.onValueChange     = onValueChange
	self.flags             = flags
	convar.convars[ name ] = self
end

local n = 0

function convar:getBoolean()
	n = self:getNumber()
	return n ~= nil and n ~= 0
end

function convar:getDefault()
	return self.default
end

function convar:getFlags()
	return self.flags
end

function convar:getHelpString()
	return self.helpString
end

function convar:getMin()
	return self.min
end

function convar:getMax()
	return self.max
end

function convar:getName()
	return self.name
end

function convar:getNumber()
	return tonumber( self.value )
end

function convar:getValue()
	return self.value
end

function convar:onValueChange( oldValue, newValue )
end

function convar:remove()
	convar.convars[ self:getName() ] = nil
end

function convar:setDefault( default )
	self.default = default
end

function convar:setFlags( flags )
	self.flags = flags
end

function convar:setMin( min )
	self.min = min
end

function convar:setMax( max )
	self.max = max
end

function convar:setHelpString( helpString )
	self.helpString = helpString
end

local oldValue    = nil
local numberValue = 0

function convar:setValue( value )
	oldValue   = self.value
	self.value = value

	numberValue = tonumber( self.value )
	if ( ( type( self.value ) == "number" or numberValue ) and
	     ( self.min and self.max ) ) then
		self.value = math.min( self.max, math.max( self.min, numberValue ) )
	end

	if ( _SERVER ) then
		local flags = self:getFlags()
		if ( flags ) then
			local notify = table.hasvalue( flags, "notify" )
			if ( notify ) then
				local name = self:getName()
				local text = "Server cvar " .. name .. " changed to " .. self.value
				player.sendTextAll( text )
				return true
			end
		end
	end

	self:onValueChange( oldValue, value )
end

function convar:__tostring()
	return "convar: " .. self.name .. " = \"" .. self.value .. "\""
end
