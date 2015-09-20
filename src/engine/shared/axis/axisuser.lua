--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Axis User class
--
--============================================================================--

class( "axisuser" )

function axisuser:axisuser( username, email, ticket )
	self.username = username
	self.email    = email
	self.ticket   = ticket
end

local URL_GRAVATAR_BASE = "https://www.gravatar.com/avatar"

local function getSavedAvatarFilename( self )
	local files = filesystem.getDirectoryItems( "downloads/avatars" )
	for i, filename in ipairs( files ) do
		if ( string.find( filename, self:getEmailHash() ) ) then
			return filename
		end
	end
end

function axisuser:downloadAvatar( callback )
	require( "engine.shared.socket.http" )
	require( "engine.shared.socket.https" )

	local hash  = self:getEmailHash()
	local query = http.urlencode( {
		default = 404,
		size    = 44
	} )
	local url = URL_GRAVATAR_BASE .. "/" .. hash .. "?" .. query

	local filename = getSavedAvatarFilename( self )
	local headers
	if ( filename ) then
		headers = {}
		local path         = "downloads/avatars/" .. filename
		local lastModified = os.date( "%a, %d %b %Y %X GMT",
		                     filesystem.getLastModified( path ) )
		headers[ 'If-Modified-Since' ] = lastModified
	end

	local _callback = function( r, c, h, s )
		if ( c == 200 ) then
			filesystem.createDirectory( "downloads/avatars" )
			local filename = string.match( h[ 'content-disposition' ],
			                               "filename=\"(.-)\"" )
			filename = "downloads/avatars/" .. filename
			if ( filesystem.write( filename, r ) ) then
				print( "Got avatar for " .. hash .. "!" )
			else
				print( "Failed to save avatar for " .. hash .. "!" )
			end
		elseif ( c == 304 ) then
			print( "Avatar for " .. hash .. " is up-to-date!" )
		end

		if ( callback ) then
			callback( r, c, h, s )
		end
	end

	if ( headers ) then
		local options = {
			url     = url,
			headers = headers
		}
		https.request( options, nil, _callback )
	else
		https.request( url, nil, _callback )
	end
end

function axisuser:getAvatarImage()
	if ( self.avatar ) then
		return self.avatar
	end

	local filename = getSavedAvatarFilename( self )
	if ( not filename ) then
		return nil
	end

	self.avatar = graphics.newImage( "downloads/avatars/" .. filename )
	return self.avatar
end

function axisuser:getUsername()
	return self.username
end

function axisuser:getEmail()
	return self.email
end

function axisuser:getEmailHash()
	_G.md5 = require( "public.md5" )
	return md5.sumhexa( string.trim( self.email ) )
end

function axisuser:getTicket()
	return self.ticket
end

function axisuser:__tostring()
	return "axisuser: \"" .. self.username .. "\""
end
