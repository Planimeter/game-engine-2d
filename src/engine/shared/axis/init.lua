--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Axis interface
--
--============================================================================--

-- These values are preserved during real-time scripting.
local account      = axis and axis.getCurrentUser()

local class        = class
local filesystem   = filesystem
local ipairs       = ipairs
local require      = require
local setmetatable = setmetatable
local string       = string
local _G           = _G

module( "axis" )

URL_WEBAPI_BASE = "http://api.andrewmcwatters.com/axis"

function authenticate( ticket, callback )
	local url = URL_WEBAPI_BASE .. "/authenticate"

	require( "engine.shared.socket.http" )
	require( "engine.shared.socket.https" )

	local body = _G.http.urlencode( {
		ticket = ticket
	} )

	local _callback = function( r, c, h, s )
		if ( _G._SERVER and c == 200 ) then
			require( "public.json" )
			require( "engine.shared.axis.axisuser" )

			local account  = _G.json.decode( r )
			local username = account.username
			local email    = account.email
			local ticket   = account.ticket
			local user     = _G.axisuser( username, email, ticket )
			local players  = _G.player.getAll()
			for _, player in ipairs( players ) do
				if ( player.ticket == ticket ) then
					player.ticket  = nil
					player.account = user
				end
			end
		end

		callback( r, c, h, s )
	end

	_G.https.request( url, body, _callback )
end

function createAccount( username, password, email, callback )
	local url = URL_WEBAPI_BASE .. "/account"
	require( "engine.shared.socket.http" )
	require( "engine.shared.socket.https" )
	local body = _G.http.urlencode( {
		username = username,
		password = password,
		email    = email
	})
	_G.https.request( url, body, callback )
end

function getAccount( username, callback )
	require( "engine.shared.socket.http" )
	require( "engine.shared.socket.https" )
	local url = URL_WEBAPI_BASE .. "/account?username=" ..
	            _G.http.urlencode( username )
	_G.https.request( url, nil, callback )
end

local _account = account

function getCurrentUser()
	return _account
end

function getSavedGame( username, appSecret, name, callback )
	local url = URL_WEBAPI_BASE .. "/save"
	require( "engine.shared.socket.http" )
	require( "engine.shared.socket.https" )
	local query = _G.http.urlencode( {
		username   = username,
		app_secret = appSecret,
		name       = name
	} )
	_G.https.request( url .. "?" .. query, nil, callback )
end

function setCurrentUser( account )
	_account = account
end

function setSavedGame( username, appSecret, name, save, callback )
	local url = URL_WEBAPI_BASE .. "/save"
	require( "engine.shared.socket.http" )
	require( "engine.shared.socket.https" )
	local body = _G.http.urlencode( {
		username   = username,
		app_secret = appSecret,
		name       = name,
		save       = save
	} )
	_G.https.request( url, body, callback )
end

function signin( username, password, callback )
	local url = URL_WEBAPI_BASE .. "/signin"

	require( "engine.shared.socket.http" )
	require( "engine.shared.socket.https" )

	local body = _G.http.urlencode( {
		username = username,
		password = password
	} )

	local _callback = function( r, c, h, s )
		if ( _G._CLIENT and c == 200 ) then
			require( "public.json" )
			require( "engine.shared.axis.axisuser" )

			local account  = _G.json.decode( r )
			local username = account.username
			local email    = account.email
			local ticket   = account.ticket
			local user     = _G.axisuser( username, email, ticket )
			setCurrentUser( user )
		end

		callback( r, c, h, s )
	end

	_G.https.request( url, body, _callback )
end
