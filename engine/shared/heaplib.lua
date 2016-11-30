--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Binary heap library
--
--============================================================================--

class( "heap" )

local function getparentindex( i )
	return i % 2 == 0 and i / 2 or ( i - 1 ) / 2
end

local function upheap( self, i )
	if ( i <= 1 ) then
		return
	end

	local parent = getparentindex( i )
	if ( self[ parent ] >= self[ i ] ) then
		self[ parent ], self[ i ] = self[ i ], self[ parent ]
		upheap( self, parent )
	end
end

function heap:insert( value )
	table.insert( self, value )
	upheap( self, #self )
end

local function getleftchildindex( i )
	return 2 * i
end

local function getrightchildindex( i )
	return 2 * i + 1
end

local function downheap( self, i )
	local rindex = getrightchildindex( i )
	local size   = #self
	local lindex = getleftchildindex( i )
	local min
	if ( rindex > size ) then
		if ( lindex > size ) then
			return
		else
			min = lindex
		end
	else
		if ( self[ lindex ] < self[ rindex ] ) then
			min = lindex
		else
			min = rindex
		end
	end
	if ( self[ i ] >= self[ min ] ) then
		self[ i ], self[ min ] = self[ min ], self[ i ]
		downheap( self, min )
	end
end

function heap:remove( pos )
	local size   = #self
	self[ pos ]  = self[ size ]
	self[ size ] = nil
	if ( size > 1 ) then
		downheap( self, 1 )
	end
end

function heap:__tostring()
	local t = getmetatable( self )
	setmetatable( self, {} )
	local s = string.gsub( tostring( self ), "table", "heap" )
	setmetatable( self, t )
	return s
end
