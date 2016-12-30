--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Convar class
--
--============================================================================--

require( "class" )

class( "convar" )

convar.config  = convar.config  or {}
convar.convars = convar.convars or {}

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
	if ( not love.filesystem.exists( "cfg/config.cfg" ) ) then
		return
	end

	for line in love.filesystem.lines( "cfg/config.cfg" ) do
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

	love.filesystem.createDirectory( "cfg" )

	if ( love.filesystem.write( "cfg/config.cfg", config ) ) then
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

function convar:getBoolean()
	local n = self:getNumber()
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

function convar:setValue( value )
	local oldValue = self.value
	self.value     = value

	local numberValue = tonumber( self.value )
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
