--========= Copyright © 2013-2014, Planimeter, All rights reserved. ==========--
--
-- Purpose: Extends the string library
--
--============================================================================--

require( "string" )
require( "public.utf8data" )
require( "public.utf8" )

local sub	 = string.utf8sub
local upper	 = string.utf8upper
local gmatch = string.gmatch
local gsub	 = string.gsub
local find	 = string.find

function string.capitalize( s )
	return upper( sub( s, 1, 1 ) ) .. sub( s, 2 )
end

function string.split( s, separator )
	local t = {}
	for token in gmatch( s, "[^" .. separator .. "]+" ) do
		table.insert( t, token )
	end
	return t
end

function string.trim( s )
	return gsub( s, "^%s*(.-)%s*$", "%1" )
end

function string.fixslashes( path )
	return gsub( path, "\\", "/" )
end

function string.ispathabsolute( path )
	path = string.fixslashes( path )
	if ( find( path, "/" ) == 1 or find( path, "%a:" ) == 1 ) then
		return true
	end
	return false
end
