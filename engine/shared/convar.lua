--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: Convar class
--
--==========================================================================--

require( "class" )

class( "convar" )

convar._config  = convar._config  or {}
convar._convars = convar._convars or {}

function convar.getConfig( name )
	return convar._config[ name ]
end

function convar.getConvar( name )
	return convar._convars[ name ]
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
	if ( love.filesystem.getInfo( "cfg/config.cfg" ) == nil ) then
		return
	end

	for line in love.filesystem.lines( "cfg/config.cfg" ) do
		for k, v in string.gmatch( line, "(.+)%s(.+)" ) do
			convar._config[ k ] = v
		end
	end
end

function convar.saveConfig()
	local config = {}
	for k, v in pairs( convar._convars ) do
		if ( v:isFlagSet( "archive" ) ) then
			table.insert( config, k .. " " .. tostring( v:getValue() ) )
		end
	end
	table.sort( config )
	table.insert( config, "" )
	config = table.concat( config, "\r\n" )

	love.filesystem.createDirectory( "cfg" )

	if ( love.filesystem.write( "cfg/config.cfg", config ) ) then
		print( "Saved configuration." )
	else
		print( "Failed to save configuration!" )
	end
end

function convar:convar(
	name,
	default,
	min,
	max,
	helpString,
	onValueChange,
	flags
)
	local value = convar._config[ name ] or default
	if ( convar._convars[ name ] ) then
		value = convar._convars[ name ]:getValue()
	end

	self.name               = name
	self.default            = default
	self.value              = value
	self.min                = min
	self.max                = max
	self.helpString         = helpString
	self.onValueChange      = onValueChange
	self.flags              = flags
	convar._convars[ name ] = self
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

function convar:isFlagSet( flag )
	local flags = self:getFlags()
	if ( flags ) then
		return table.hasvalue( flags, flag ) ~= nil
	end

	return false
end

function convar:onValueChange( oldValue, newValue )
end

function convar:remove()
	convar._convars[ self:getName() ] = nil
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
		local shouldNotify = self:isFlagSet( "notify" )
		if ( shouldNotify ) then
			local name = self:getName()
			local text = "Server cvar " .. name .. " changed to " .. self.value
			player.sendTextAll( text )
			return true
		end
	end

	self:onValueChange( oldValue, value )
end

function convar:__tostring()
	return "convar: " .. self.name .. " = \"" .. self.value .. "\""
end
