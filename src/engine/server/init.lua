--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Engine server interface
--
--============================================================================--

require( "engine.server.network" )
require( "engine.shared.network.payload" )

local _AXIS		   = _AXIS

local convar	   = convar
local debug		   = debug
local getmetatable = getmetatable
local filesystem   = filesystem
local network	   = engine.server.network
_G.networkserver   = network
local love		   = love
local payload	   = payload
local print		   = print
local region	   = region
local require	   = require
local setmetatable = setmetatable
local string	   = string
local table		   = table
local tostring	   = tostring
local unrequire	   = unrequire
local _G		   = _G

module( "engine.server" )

local function error_printer(msg, layer)
	print((debug.traceback("Error: " ..
		  tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", "")))
end

function errhand(msg)
	msg = tostring(msg)

	error_printer(msg, 2)

	while true do
		if love.timer then
			love.timer.sleep(0.1)
		end
	end

end

function load( arg )
	local initialized = network.initializeServer()
	if ( not initialized ) then
		-- print( "Failed to initialize server!" )
		return false
	end

	require( "game" )

	_G.gameserver = require( "game.server" )
	_G.gameserver.load( arg )

	return true
end

function onConnect( event )
	print( tostring( event.peer ) .. " has connected." )

	require( "engine.shared.entities.player" )
	local player = _G.player.initialize( event.peer )
	player:onConnect()

	-- TODO: Initialize specific player class here.

	if ( not _AXIS ) then
		sendServerInfo( player )
	end
end

local directoryWhitelist = {
	"regions"
}

local function onDownloadRequest( payload )
	local filename = payload:get( "filename" )
	if ( not filename ) then
		return
	end

	filename   = string.fixslashes( filename )
	local peer = payload:getPeer()

	print( tostring( peer ) .. " requested \"" .. filename .. "\"..." )

	if ( string.find( filename, "/..", 1, true ) or
		 string.ispathabsolute( filename ) ) then
		print( "Access denied to " .. tostring( peer ) .. "!" )
		return
	end

	if ( not filesystem.exists( filename ) ) then
		print( filename .. " does not exist!" )
		return
	end

	local directory = string.match( filename, "(.-)/" )
	if ( not directory or
		 not table.hasvalue( directoryWhitelist, directory ) ) then
		print( tostring( peer ) ..
			   " requested file outside of directory whitelist (" ..
			   directory .. ")!" )
		return
	end

	upload( filename, peer )
end

payload.setHandler( onDownloadRequest, "download" )

local sv_payload_show_receive = convar( "sv_payload_show_receive", "0", nil, nil,
										"Prints payloads received from clients" )

if ( _G._DEBUG ) then
	sv_payload_show_receive:setValue( "1" )
end

function onReceive( event )
	local payload = payload.initializeFromData( event.data )
	payload:setPeer( event.peer )

	if ( sv_payload_show_receive:getBoolean() ) then
		print( "Received payload \"" .. payload:getStructName() .. "\" from " ..
			   tostring( payload:getPeer() ) .. ":" )
		table.print( payload:getData(), 1 )
	end

	payload:dispatchToHandler()
end

function onDisconnect( event )
	local player = _G.player.getByPeer( event.peer )
	if ( player ) then
		player:onDisconnect()

		if ( _AXIS ) then
			local account = player:getAccount()
			if ( account ) then
				local username = account:getUsername()
				print( "Player " .. username .. " has left the game." )
			end
		end

		player:remove()
	end

	print( tostring( event.peer ) .. " has disconnected." )
end

if ( _AXIS ) then
	local function onPlayerAuthenticateHandler( payload )
		local player = _G.player.getByPeer( payload:getPeer() )
		local ticket = payload:get( "ticket" )
		onPlayerAuthenticate( player, ticket )
	end

	payload.setHandler( onPlayerAuthenticateHandler, "authenticate" )

	function onPlayerAuthenticate( player, ticket )
		player.think  = nil
		player.ticket = ticket

		require( "engine.shared.axis" )
		_G.axis.authenticate( ticket, function( r, c, h, s )
			if ( c == 200 ) then
				player:setAuthenticated( true )

				local account = player:getAccount()
				if ( account ) then
					local username = account:getUsername()
					player:setName( username )
					print( "Player " .. username .. " has joined the game." )
					player:onAuthenticated()
					sendServerInfo( player )
				else
					-- Player disconnected during authentication phase
				end
			else
				player:kick( "Axis authentication failed!" )
			end
		end )
	end
end

local function onReceiveClientInfo( payload )
	local player		 = _G.player.getByPeer( payload:getPeer() )
	local viewportWidth	 = payload:get( "viewportWidth" )
	local viewportHeight = payload:get( "viewportHeight" )
	player:setViewportSize( viewportWidth, viewportHeight )
	player:initialSpawn()
end

payload.setHandler( onReceiveClientInfo, "clientInfo" )

function quit()
	if ( _G.game and _G.game.server ) then
		 _G.game.server.shutdown()
		 _G.game.server = nil
	end

	unrequire( "game" )

	network.shutdownServer()

	region.unloadAll()

	unrequire( "engine.server.network" )
	_G.networkserver = nil
	unrequire( "engine.server" )
	_G.serverengine = nil
end

if ( _AXIS ) then
	function setSavedGame( player, save )
		require( "common.vector" )
		local x = save.position.x
		local y = save.position.y
		player:setPosition( _G.vector( x, y ) )
	end

	function sendSavedGame( player )
		require( "engine.shared.axis" )
		local account	= player:getAccount()
		local username 	= account:getUsername()
		local appSecret = _G.game.appSecret
		_G.axis.getSavedGame( username, appSecret, nil, function( r, c, h, s )
			local payload = payload( "serverInfo" )

			require( "public.json" )

			local save = nil

			if ( c == 200 ) then
				-- FIXME; Decode twice since we get back escaped save data.
				save = _G.json.decode( r )
				save = _G.json.decode( save )
				_G.region.load( save.region )
			elseif ( c == 404 ) then
				local region = _G.game.getStartingRegion()
				_G.region.load( region )

				save = player:createInitialSave( region )
				local r = _G.json.encode( save )
				_G.axis.setSavedGame( username, appSecret, nil, r )
			end

			setSavedGame( player, save )

			payload:set( "region", save.region )
			payload:set( "save", c == 200 and r or _G.json.encode( save ) )
			player:send( payload )
		end )
	end
end

function sendServerInfo( player )
	if ( _AXIS ) then
		if ( _G.game.usesAxisSavedGames() ) then
			sendSavedGame( player )
		end
		return
	end

	local payload = payload( "serverInfo" )
	payload:set( "region", _G.game.getStartingRegion() )
	player:send( payload )
end

shutdown = quit

function update( dt )
	require( "engine.shared.entities.player" )
	_G.player.updatePlayers( dt )

	network.update( dt )
end

function upload( filename, peer )
	local payload = payload( "upload" )
	payload:set( "filename", filename )
	payload:set( "file", filesystem.read( filename ) )
	peer:send( payload:serialize() )
end
