--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Pathfinding interface
--
--============================================================================--

if ( _CLIENT ) then
require( "engine.client.debugoverlay" )
end

require( "engine.shared.path.node" )
require( "engine.shared.heaplib" )

local math         = math
local region       = region
local require      = require
local table        = table
local tostring     = tostring
local vector       = vector
local _G           = _G

module( "path" )

local _directions = 8

function getDirections()
	return _directions
end

local function snapToGrid( v )
	return vector( region.snapToGrid( v.x, v.y ) )
end

local merge = table.merge

local function getSuccessors( q, closed )
	local successors = {}
	local region     = region.getAtPosition( q )
	if ( not region ) then
		return successors
	end

	local x, y = q.x, q.y
	local w, h = region:getTileSize()

	local node = _G.node
	local directions = {
		[ 1 ] = node( x, y - h, q ), -- North
		[ 3 ] = node( x + w, y, q ), -- East
		[ 5 ] = node( x, y + h, q ), -- South
		[ 7 ] = node( x - w, y, q )  -- West
	}

	local numDirections = getDirections()
	if ( numDirections == 8 ) then
		merge( directions, {
			[ 2 ] = node( x + w, y - h, q ), -- North East
			[ 4 ] = node( x + w, y + h, q ), -- South East
			[ 6 ] = node( x - w, y + h, q ), -- South West
			[ 8 ] = node( x - w, y - h, q )  -- North West
		} )
	end

	for i = 1, 8, 8 / numDirections do
		local position = directions[ i ]
		if ( region:isTileWalkableAtPosition( position ) ) then
			table.insert( successors, position )
		end
	end

	return successors
end

local abs  = math.abs
local max  = math.max
local sqrt = math.sqrt

local heuristics = {
	[ "manhattan" ] = function( a, b )
		local dx = abs( a.x - b.x )
		local dy = abs( a.y - b.y )
		return dx + dy
	end,
	[ "chebyshev" ] = function( a, b )
		local dx = abs( a.x - b.x )
		local dy = abs( a.y - b.y )
		return max( dx, dy )
	end,
	[ "euclidean" ] = function( a, b )
		local dx = abs( a.x - b.x )
		local dy = abs( a.y - b.y )
		return sqrt( dx * dx + dy * dy )
	end
}

local _heuristic = "euclidean"

function getHeuristic()
	return _heuristic
end

local function getDistance( a, b )
	return heuristics[ getHeuristic() ]( a, b )
end

local function reconstructPath( node )
	local path = {}
	while ( node.parent ) do
		table.insert( path, 1, vector.copy( node ) )
		node = node.parent
	end
	return path
end

function getPath( start, goal )
	local region = region.getAtPosition( goal )
	if ( not region ) then
		return
	end

	start = snapToGrid( start )
	goal  = snapToGrid( goal )
	if ( start == goal ) then
		return
	end

	local heap   = _G.heap
	local open   = heap()
	local closed = {}

	local node = _G.node
	start      = node( start.x, start.y )
	heap.insert( open, start )

	while ( #open ~= 0 ) do
		local q = open[ 1 ]
		heap.remove( open, 1 )
		closed[ tostring( q ) ] = true
		local successors = getSuccessors( q, closed )
		for i = 1, #successors do
			local successor = successors[ i ]
			if ( successor == goal ) then
				return reconstructPath( successor )
			end

			successor.g = q.g + getDistance( successor, q )
			successor.h = getDistance( goal, successor )
			successor.f = successor.g + successor.h

			if ( not table.hasvalue( open, successor ) and
			     not closed[ tostring( successor ) ] ) then
				heap.insert( open, successor )
			end
		end
	end
end

function setDirections( directions )
	_directions = directions
end

function setHeuristic( heuristic )
	_heuristic = heuristic
end
