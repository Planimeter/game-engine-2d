--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: Network Variable class
--
--==========================================================================--

class( "networkvar" )

function networkvar:networkvar( entity, name )
	self.entity = entity
	self.name   = name
end

function networkvar:onValueChanged()
	local entity = self.entity
	if ( entity == nil ) then
		return
	end

	entity:onNetworkVarChanged( self )
end

accessor( networkvar, "name" )
accessor( networkvar, "value" )

function networkvar:setValue( value )
	local oldValue = self.value
	self.value     = value
	if ( oldValue ~= value ) then
		self:onValueChanged()
	end
end

function networkvar:__tostring()
	local value = "\"" .. tostring( self.value ) .. "\""
	if ( self.value == nil ) then
		value = "nil"
	end
	return "networkvar: " .. self.name .. " = " .. value
end
