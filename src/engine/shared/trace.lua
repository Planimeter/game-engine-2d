--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Trace class
--
--============================================================================--

class( "trace" )

function trace:trace( startPos, endPos, callback )
	self.startPos = startPos
	self.endPos   = endPos
	local world   = nil
	world:rayCast( startPos.x, startPos.y, endPos.x, endPos.y, callback )
end
