--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Extends the string library
--
--============================================================================--

require( "string" )
require( "public.utf8data" )
require( "public.utf8" )

local sub    = string.utf8sub
local upper  = string.utf8upper
local len    = string.utf8len
local find   = string.find
local gmatch = string.gmatch
local gsub   = string.gsub

function string.capitalize( s )
	return upper( sub( s, 1, 1 ) ) .. sub( s, 2 )
end

function string.parseArgs( s )
	local t      = {}
	local i      = 1
	local length = len( s )
	while ( i <= length ) do
		if ( sub( s, i, i ) == "\"" ) then
			local char = find( s, "\"", i + 1 )
			if ( char ) then
				table.insert( t, sub( s, i + 1, char - 1 ) )
				local _, endPos = find( s, "%s*.", char + 1 )
				i = endPos or char + 1
			else
				char = find( s, "%s", i + 1 )
				if ( char ) then
					table.insert( t, sub( s, i + 1, char - 1 ) )
					local _, endPos = find( s, "%s*.", char + 1 )
					i = endPos or char + 1
				else
					table.insert( t, sub( s, i + 1 ) )
					i = length + 1
				end
			end
		else
			local char = find( s, "%s", i + 1 )
			if ( char ) then
				table.insert( t, sub( s, i, char - 1 ) )
				local _, endPos = find( s, "%s*.", char + 1 )
				i = endPos or char + 1
			else
				table.insert( t, sub( s, i ) )
				i = length + 1
			end
		end
	end

	return t
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
