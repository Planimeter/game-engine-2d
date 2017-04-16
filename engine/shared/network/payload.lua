--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Payload class
--
--============================================================================--

require( "engine.shared.typelenvalues" )

class "payload" ( "typelenvalues" )

payload.handlers = payload.handlers or {}

-- Generate ids for packet structures
do
	local payloads = "engine.shared.network.payloads"
	if ( package.loaded[ payloads ] ) then
		unrequire( payloads )
	end

	require( payloads )

	typelenvalues.generateIds( payload.structs )
end

function payload.initializeFromData( data )
	local payload = payload()
	payload.data  = data
	payload:deserialize()
	return payload
end

function payload.setHandler( func, struct )
	payload.handlers[ struct ] = func
end

function payload:payload( struct )
	typelenvalues.typelenvalues( self, payload.structs, struct )
end

function payload:dispatchToHandler()
	local name = self:getStructName()
	if ( not name ) then return end

	local handler = payload.handlers[ name ]
	if ( handler ) then handler( self ) end
end

accessor( payload, "peer" )

function payload:getPlayer()
	return player.getByPeer( self.peer )
end
