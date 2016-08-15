--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Extends the debug library
--
--============================================================================--

require( "debug" )

function debug.getparameters( f )
	local info = debug.getinfo( f, "u" )
	local params = {}
	for i = 1, info.nparams do
		params[ i ] = debug.getlocal( f, i )
	end
	return params, info.isvararg
end
