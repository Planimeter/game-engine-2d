--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Payload class
--
--============================================================================--

require( "engine.shared.typelenvalues" )

local accessor      = accessor
local package       = package
local require       = require
local typelenvalues = typelenvalues
local unrequire     = unrequire
local _G            = _G

module( "payload", package.class, package.inherit( "typelenvalues" ) )

handlers = handlers or {}

-- Generate ids for packet structures
do
	local payloads = "engine.shared.network.payloads"
	if ( package.loaded[ payloads ] ) then
		unrequire( payloads )
	end

	require( payloads )

	typelenvalues.generateIds( _structs )
end

function initializeFromData( data )
	local payload = _M()
	payload.data  = data
	payload:deserialize()
	return payload
end

function setHandler( func, struct )
	handlers[ struct ] = func
end

function _M:payload( struct )
	typelenvalues.typelenvalues( self, structs, struct )
end

function _M:dispatchToHandler()
	local name = self:getStructName()
	if ( not name ) then return end

	local handler = handlers[ name ]
	if ( handler ) then handler( self ) end
end

accessor( _M, "peer" )

function _M:getPlayer()
	return _G.player.getByPeer( self.peer )
end
