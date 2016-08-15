--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Engine loader
--
--============================================================================--

require( "engine.shared.baselib" )
require( "engine.shared.tablib" )
require( "engine.shared.strlib" )
require( "engine.shared.mathlib" )
require( "engine.shared.addon" )
require( "engine.shared.filesystem" )
require( "engine.client.gui" )
require( "engine.shared.region" )

if ( _CLIENT ) then
	require( "engine.client" )
	love.draw = engineclient.draw
end

if ( _SERVER ) then
	require( "engine.server" )
	love.errhand = engineserver.errhand
end

-- Standard callback handlers
for k in pairs( love.handlers ) do
	love[ k ] = function( ... )
		if ( not _CLIENT ) then return end
		local v = engineclient[ k ]
		if ( v ) then return v( ... ) end
	end
end
