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

function node:getParent()
	return self.parent
end

function node:setParent( node )
	self.parent = node
end

node.__eq = vector.__eq

function node:__lt( n )
	return self.f < n.f
end

function node:__le( n )
	return self.f <= n.f
end

function node:__tostring()
	return "node: (" .. self.x .. ", " .. self.y .. ")"
end
