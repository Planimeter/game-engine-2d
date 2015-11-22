--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Engine server interface
--
--============================================================================--

require( "engine.server.network" )
require( "engine.shared.network.payload" )

local _AXIS        = _AXIS

local concommand   = concommand
local convar       = convar
local debug        = debug
local getmetatable = getmetatable
local ipairs       = ipairs
local filesystem   = filesystem
local network      = engine.server.network
_G.networkserver   = network
local love         = love
local payload      = payload
local print        = print
local region       = region
local require      = require
local setmetatable = setmetatable
local string       = string
local table        = table
local tostring     = tostring
local unrequire    = unrequire
local _G           = _G

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

	if ( _AXIS ) then
		-- Post-connect occurs post-authenticate
		return
	end

	onPostConnect( event )
end

local players = {}

local function getAccount( player, peer )
	for i, v in ipairs( players ) do
		if ( v.peer == peer ) then
			player.account = v.account
			table.remove( players, i )
		end
	end
end

function onPostConnect( event )
	-- Initialize region
	local region = _G.game.initialRegion
	_G.region.load( region )

	-- Initialize player
	require( "engine.shared.entities.player" )
	local player = _G.player.initialize( event.peer )

	if ( _AXIS ) then
		getAccount( player, event.peer )
	end

	player:onConnect()

	-- Set spawn point
	local spawnpoint = _G.gameserver.getSpawnPoint( player )
	if ( spawnpoint ) then
		local position = spawnpoint:getPosition()
		player:setNetworkVar( "position", position )
	end

	-- Send server info
	if ( _AXIS ) then
		local account = player:getAccount()
		if ( account ) then
			local username = account:getUsername()
			player:setNetworkVar( "name", username )
			print( "Player " .. username .. " has joined the game." )
			player:onAuthenticated()
			sendServerInfo( player )
		else
			-- Player disconnected during authentication phase
		end
	else
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
		local peer   = payload:getPeer()
		local ticket = payload:get( "ticket" )
		local player = {
			peer   = peer,
			ticket = ticket
		}
		table.insert( players, player )
		onPlayerAuthenticate( peer, ticket )
	end

	payload.setHandler( onPlayerAuthenticateHandler, "authenticate" )

	function onPlayerAuthenticate( peer, ticket )
		require( "engine.shared.axis" )
		_G.axis.authenticate( ticket, onPostPlayerAuthenticate( peer ) )
	end

	local function kick( peer, message )
		local payload = payload( "kick" )
		payload:set( "message", message )
		peer:send( payload:serialize() )
		peer:disconnect_later()
	end

	local function setAccount( peer, r )
		require( "public.json" )
		require( "engine.shared.axis.axisuser" )

		local account  = _G.json.decode( r )
		local username = account.username
		local email    = account.email
		local ticket   = account.ticket
		local user     = _G.axisuser( username, email, ticket )
		for _, player in ipairs( players ) do
			if ( player.ticket == ticket ) then
				player.ticket  = nil
				player.account = user
			end
		end
	end

	function onPostPlayerAuthenticate( peer )
		return function( r, c, h, s )
			if ( c ~= 200 ) then
				kick( peer, "Axis authentication failed!" )
				return
			end

			setAccount( peer, r )

			local event = {
				peer = peer
			}
			onPostConnect( event )
		end
	end
end

local function sendEntities( player )
	local entities = _G.entity.getAll()
	for _, entity in ipairs( entities ) do
		if ( entity ~= player ) then
			local payload = payload( "entitySpawned" )
			payload:set( "classname", entity:getClassname() )
			payload:set( "entIndex", entity.entIndex )
			payload:set( "networkVars", entity:getNetworkVarTypeLenValues() )
			player:send( payload )
		end
	end
end

local function onReceiveClientInfo( payload )
	local player         = payload:getPlayer()
	local viewportWidth	 = payload:get( "viewportWidth" )
	local viewportHeight = payload:get( "viewportHeight" )
	player:setViewportSize( viewportWidth, viewportHeight )

	sendEntities( player )

	player:initialSpawn()
end

payload.setHandler( onReceiveClientInfo, "clientInfo" )

local function onReceiveConcommand( payload )
	local player    = payload:getPlayer()
	local name      = payload:get( "name" )
	local argString = payload:get( "argString" )
	if ( player == _G.localplayer ) then
		return
	end

	concommand.dispatch( player, name, argString, argTable )
end

payload.setHandler( onReceiveConcommand, "concommand" )

function quit()
	if ( _G.game and _G.game.server ) then
		 _G.game.server.shutdown()
		 _G.game.server = nil
	end

	unrequire( "game" )
	_G.game = nil

	network.shutdownServer()

	region.unloadAll()

	unrequire( "engine.server.network" )
	_G.networkserver = nil
	unrequire( "engine.server" )
	_G.serverengine = nil
end

function sendServerInfo( player )
	if ( _AXIS ) then
		require( "engine.shared.axis" )
		local account	= player:getAccount()
		local username 	= account:getUsername()
		local appSecret = _G.game.appSecret
		_G.axis.getSavedGame( username, appSecret, nil, onGetSavedGame( player ) )
		return
	end

	local payload = payload( "serverInfo" )
	payload:set( "region", _G.game.initialRegion )
	player:send( payload )
end

function onGetSavedGame( player )
	return function( r, c, h, s )
		-- Server shutdown before operation completed.
		if ( not _G.game ) then
			return
		end

		local payload = payload( "serverInfo" )

		require( "public.json" )

		local save = nil

		if ( c == 200 ) then
			-- FIXME; Decode twice since we get back escaped save data.
			save = _G.json.decode( r )
			save = _G.json.decode( save )
		elseif ( c == 404 ) then
			save = player:createInitialSave()
			local r = _G.json.encode( save )
			_G.axis.setSavedGame( username, appSecret, nil, r )
		end

		payload:set( "region", save.region )
		payload:set( "save", c == 200 and r or _G.json.encode( save ) )
		player:send( payload )
	end
end

shutdown = quit

function update( dt )
	network.update( dt )
end

function upload( filename, peer )
	local payload = payload( "upload" )
	payload:set( "filename", filename )
	payload:set( "file", filesystem.read( filename ) )
	peer:send( payload:serialize() )
end
