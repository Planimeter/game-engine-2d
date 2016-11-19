--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Convar class
--
--============================================================================--

require( "class" )

local love     = love
local math     = math
local pairs    = pairs
local print    = print
local string   = string
local table    = table
local tonumber = tonumber
local tostring = tostring
local _G       = _G

module( "convar", package.class )

config  = config  or {}
convars = convars or {}

function getConfig( name )
	return config[ name ]
end

function getConvar( name )
	return convars[ name ]
end

function setConvar( name, value )
	local convar = getConvar( name )
	if ( convar ) then
		convar:setValue( value )
		return true
	else
		return false
	end
end

function readConfig()
	if ( not love.filesystem.exists( "cfg/config.cfg" ) ) then
		return
	end

	for line in love.filesystem.lines( "cfg/config.cfg" ) do
		for k, v in string.gmatch( line, "(.+)%s(.+)" ) do
			config[ k ] = v
		end
	end
end

function saveConfig()
	local config = {}
	for k, v in pairs( convars ) do
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

function _M:convar( name, default, min, max, helpString, onValueChange, flags )
	self.name          = name
	self.default       = default
	self.value         = config[ name ] or default
	self.min           = min
	self.max           = max
	self.helpString    = helpString
	self.onValueChange = onValueChange
	self.flags         = flags
	convars[ name ]    = self
end

function _M:getBoolean()
	local n = self:getNumber()
	return n ~= nil and n ~= 0
end

function _M:getDefault()
	return self.default
end

function _M:getFlags()
	return self.flags
end

function _M:getHelpString()
	return self.helpString
end

function _M:getMin()
	return self.min
end

function _M:getMax()
	return self.max
end

function _M:getName()
	return self.name
end

function _M:getNumber()
	return tonumber( self.value )
end

function _M:getValue()
	return self.value
end

function _M:onValueChange( oldValue, newValue )
end

function _M:remove()
	convars[ self:getName() ] = nil
end

function _M:setDefault( default )
	self.default = default
end

function _M:setFlags( flags )
	self.flags = flags
end

function _M:setMin( min )
	self.min = min
end

function _M:setMax( max )
	self.max = max
end

function _M:setHelpString( helpString )
	self.helpString = helpString
end

function _M:setValue( value )
	local oldValue = self.value
	self.value     = value

	local numberValue = tonumber( self.value )
	if ( ( type( self.value ) == "number" or numberValue ) and
	     ( self.min and self.max ) ) then
		self.value = math.min( self.max, math.max( self.min, numberValue ) )
	end

	if ( _G._SERVER ) then
		local flags = self:getFlags()
		if ( flags ) then
			local notify = table.hasvalue( flags, "notify" )
			if ( notify ) then
				local name = self:getName()
				local text = "Server cvar " .. name .. " changed to " .. self.value
				_G.player.sendTextAll( text )
				return true
			end
		end
	end

	self:onValueChange( oldValue, value )
end

function _M:__tostring()
	return "convar: " .. self.name .. " = \"" .. self.value .. "\""
end
