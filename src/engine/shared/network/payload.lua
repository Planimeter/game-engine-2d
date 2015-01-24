--========= Copyright © 2013-2014, Planimeter, All rights reserved. ==========--
--
-- Purpose: Payload class
--
--============================================================================--

-- These values are preserved during real-time scripting.
local _handlers = payload and payload.handlers or {}

require( "engine.shared.typelenvalues" )

class "payload" ( "typelenvalues" )

payload.handlers = _handlers
local handlers	 = payload.handlers

-- Generate ids for packet structures
do
	unrequire( "engine.shared.network.payloads" )
	require( "engine.shared.network.payloads" )

	typelenvalues.generateIds( payload.structs )
end

function payload.initializeFromData( data )
	local payload = payload()
	payload.data  = data
	payload:deserialize()
	return payload
end

function payload.setHandler( func, struct )
	handlers[ struct ] = func
end

function payload:payload( struct )
	typelenvalues.typelenvalues( self, payload.structs, struct )
end

function payload:dispatchToHandler()
	local name = self:getStructName()
	if ( name ) then
		local handler = handlers[ name ]
		if ( handler ) then
			handler( self )
		end
	end
end

function payload:getPeer()
	return self.peer
end

function payload:setPeer( peer )
	self.peer = peer
end
