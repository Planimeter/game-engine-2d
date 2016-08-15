--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Pathfinding Node class
--
--============================================================================--

class "node" ( "vector" )

function node:node( x, y, parent )
	vector.vector( self, x, y )
	self.parent = parent
	self.g      = 0
	self.h      = 0
	self.f      = 0
end

mutator( node, "parent" )

node.__eq = vector.__eq

function node.__lt( a, b )
	return a.f < b.f
end

function node.__le( a, b )
	return a.f <= b.f
end

function node:__tostring()
	return "node: (" .. self.x .. ", " .. self.y .. ")"
end
