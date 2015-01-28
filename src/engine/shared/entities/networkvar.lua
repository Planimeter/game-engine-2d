--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Network Variable class
--
--============================================================================--

class( "networkvar" )

function networkvar:networkvar( entity, name )
	self.entity = entity
	self.name	= name
end

function networkvar:onValueChanged()
	local entity = self.entity
	if ( entity == nil ) then
		return
	end

	entity:onNetworkVarChanged( self )
end

function networkvar:getName()
	return self.name
end

function networkvar:getValue()
	return self.value
end

function networkvar:setValue( value )
	local oldValue = self.value
	self.value	   = value
	if ( oldValue ~= value ) then
		self:onValueChanged()
	end
end

function networkvar:__tostring()
	return "networkvar: " .. self.name .. " = \"" .. tostring( self.value ) .. "\""
end
