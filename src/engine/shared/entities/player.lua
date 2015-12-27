--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Player class
--
--============================================================================--

-- These values are preserved during real-time scripting.
local players      = player and player.players      or {}
local lastPlayerId = player and player.lastPlayerId or 0

require( "engine.shared.entities.character" )

class "player" ( "character" )

player.players      = players
player.lastPlayerId = lastPlayerId

function player.initialize( peer )
	local player = _G.gameserver.getPlayerClass()()
	player.peer  = peer
	return player
end

function player.getAll()
	return table.shallowcopy( players )
end

function player.getById( id )
	for _, player in ipairs( players ) do
		if ( player:getNetworkVar( "id" ) == id ) then
			return player
		end
	end
end

function player.getByPeer( peer )
	for _, player in ipairs( players ) do
		if ( player.peer == peer ) then
			return player
		end
	end
end

function player:player()
	character.character( self )

	local tileSize = game.tileSize
	local min      = vector()
	local max      = vector( tileSize, -tileSize )
	self:setCollisionBounds( min, max )

	self:networkNumber( "id", player.lastPlayerId + 1 )
	self:networkNumber( "moveSpeed", 1 )

	if ( _SERVER ) then
		player.lastPlayerId = self:getNetworkVar( "id" )
	end

	if ( _CLIENT ) then
		require( "engine.client.sprite" )
		local sprite = sprite( "images.player" )
		self:setSprite( sprite )
	end

	table.insert( player.players, self )
end

if ( _AXIS ) then
	if ( _SERVER ) then
		function player:createInitialSave()
			local spawnPoint = gameserver.getSpawnPoint( self )
			local position = vector.origin + vector( 0, _G.game.tileSize )
			if ( spawnPoint ) then
				position = spawnPoint:getPosition()
			end

			local save = {
				region = _G.game.initialRegion,
				position = {
					x = position.x,
					y = position.y
				}
			}
			return save
		end
	end

	function player:getAccount()
		return self.account
	end
end

function player:getName()
	if ( self.account ) then
		return self.account:getUsername()
	end

	return entity.getName( self ) or "Unnamed"
end

function player:getRegion()
	return self.region
end

function player:getSave()
	return self.save
end

function player:getViewportWidth()
	return self.viewportWidth
end

function player:getViewportHeight()
	return self.viewportHeight
end

function player:getViewportBounds()
	local width  = self:getViewportWidth()  or 0
	local height = self:getViewportHeight() or 0
	local min    = self:localToWorld( vector( -width / 2,  height / 2 ) )
	local max    = self:localToWorld( vector(  width / 2, -height / 2 ) )
	return min, max
end

function player:getViewportSize()
	return self:getViewportWidth(), self:getViewportHeight()
end

function player:initialSpawn()
	if ( self.initialized ) then
		return
	else
		self.initialized = true
	end

	if ( _SERVER ) then
		self:spawn()

		local payload = payload( "playerInitialized" )
		payload:set( "entIndex", self.entIndex )
		payload:set( "id", self:getNetworkVar( "id" ) )
		self:send( payload )
	end

	game.call( "shared", "onPlayerInitialSpawn", self )
end

if ( _AXIS ) then
	function player:isAuthenticated()
		return self.authenticated
	end
end

if ( _SERVER ) then
	function player:kick( message )
		local payload = payload( "kick" )
		payload:set( "message", message )
		self.peer:send( payload:serialize() )
		self.peer:disconnect_later()
	end
end

function player:moveTo( position, callback )
	character.moveTo( self, position, callback )

	if ( _CLIENT and not _SERVER ) then
		local payload = payload( "playerMove" )
		payload:set( "position", position )
		networkclient.sendToServer( payload )
	end
end

if ( _SERVER ) then
	local function onPlayerMove( payload )
		local player   = payload:getPlayer()
		local position = payload:get( "position" )
		player.nextPosition = position
	end

	payload.setHandler( onPlayerMove, "playerMove" )
end

if ( _CLIENT ) then
	function player:onAnimationEvent( event )
		if ( event == "leftfootstep" ) then
			self:emitSound( "sounds/footsteps/grassleft.wav" )
		elseif ( event == "rightfootstep" ) then
			self:emitSound( "sounds/footsteps/grassright.wav" )
		end
	end
end

if ( _SERVER ) then
	function player:onAuthenticated()
		require( "engine.shared.hook" )
		game.call( "server", "onPlayerAuthenticated", self )
	end
end

function player:onConnect()
	require( "engine.shared.hook" )
	game.call( "shared", "onPlayerConnect", self )
end

function player:onDisconnect()
	require( "engine.shared.hook" )
	game.call( "shared", "onPlayerDisconnect", self )

	for i, player in ipairs( players ) do
		if ( player == self ) then
			table.remove( players, i )
			self:remove()
			return
		end
	end
end

concommand( "say", "Display player message",
	function( self, player, command, argString, argTable )
		if( _SERVER ) then
			if ( not game.call( "server", "onPlayerSay", player, argString ) ) then
				return
			end

			local payload = payload( "chat" )
			payload:set( "entIndex", player and player.entIndex or 0 )
			payload:set( "message", argString )

			networkserver.broadcast( payload )
		end
	end, { "network" }
)

function player:send( data, channel, flag )
	if ( type( data ) == "payload" ) then
		data = data:serialize()
	end
	self.peer:send( data, channel, flag )
end

if ( _AXIS ) then
	function player:setAuthenticated( authenticated )
		self.authenticated = authenticated
	end
end

function player:setRegion( region )
	self.region = region
end

function player:setSave( save )
	self.save = save
end

function player:setViewportWidth( viewportWidth )
	self.viewportWidth = viewportWidth
end

function player:setViewportHeight( viewportHeight )
	self.viewportHeight = viewportHeight
end

function player:setViewportSize( viewportWidth, viewportHeight )
	self:setViewportWidth( viewportWidth )
	self:setViewportHeight( viewportHeight )
end

function player:spawn()
	entity.spawn( self )
	game.call( "shared", "onPlayerSpawn", self )
end

function player:__tostring()
	return "player: " .. self:getName()
end

-- Preserve the player interface
local class = player
entities.linkToClassname( player, "player" )
_G.player = class
