--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Extends the string library
--
--============================================================================--

require( "string" )
require( "public.utf8data" )
require( "public.utf8" )

local string = string
local sub    = string.utf8sub
local upper  = string.utf8upper
local match  = string.match
local len    = string.utf8len
local find   = string.find
local gmatch = string.gmatch
local gsub   = string.gsub

function string.capitalize( s )
	return upper( sub( s, 1, 1 ) ) .. sub( s, 2 )
end

function string.fileextension( s )
	return match( s, "%.([^%.]+)$" )
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

function string.parseargs( s )
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

function string.readingtime( s )
	local text           = string.trim( s )
	local words          = string.split( text, "%s" )
	local totalWords     = #words
	local wordsPerSecond = 4.5
	return totalWords / wordsPerSecond
end

function string.split( s, separator )
	local t = {}
	for token in gmatch( s, "[^" .. separator .. "]+" ) do
		table.insert( t, token )
	end
	return t
end

function string.stripfilename( path )
	return match( path, "(.+/)[^/]*$" ) or ""
end

function string.striptrailingslash( path )
	local len = len( path )
	if ( len > 0 ) then
		local pathseparator = sub( path, len )
		if ( pathseparator == "\\" or pathseparator == "/" ) then
			return sub( path, 1, len - 1 )
		end
	end
	return path
end

function string.trim( s )
	return gsub( s, "^%s*(.-)%s*$", "%1" )
end
