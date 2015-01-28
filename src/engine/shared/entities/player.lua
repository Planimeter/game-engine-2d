--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Player class
--
--============================================================================--

-- These values are preserved during real-time scripting.
local players      = player and player.players      or {}
local lastPlayerId = player and player.lastPlayerId or 0

require( "engine.shared.entities" )
require( "engine.shared.entities.entity" )

class "player" ( "entity" )

player.players      = players
player.lastPlayerId = lastPlayerId

if ( _CLIENT ) then
	player.sprite = graphics.newImage( "images/player.png" )
end

function player.initialize( peer )
	local player = player()
	player.peer  = peer

	if ( _AXIS and _SERVER ) then
		player.authenticated = false
		player.think = function( self )
			if ( not self:isAuthenticated() ) then
				self:kick( "Axis authentication failed!" )
			end
		end
		player.nextThink = engine.getRealTime() + 4 * engine.network.timestep
	end
	return player
end

function player.getAll()
	return table.shallowcopy( players )
end

function player.getById( id )
	for _, player in ipairs( players ) do
		if ( player:getId() == id ) then
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

function player.updatePlayers( dt )
	for i, player in ipairs( players ) do
		player:update( dt )
	end
end

function player:player()
	entity.entity( self )

	self:networkNumber( "id", player.lastPlayerId + 1 )

	if ( _SERVER ) then
		player.lastPlayerId = self:getNetworkVar( "id" )
	end

	if ( _CLIENT ) then
		self:setSprite( player.sprite )
	end

	table.insert( player.players, self )
end

if ( _AXIS ) then
	if ( _SERVER ) then
		function player:createInitialSave( region )
			local spawnPoint = gameserver.getSpawnPoint( self )
			local position   = spawnPoint:getPosition()
			local save = {
				region = region,
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

	return self:getNetworkVar( "name" )
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
		payload:set( "id", self:getId() )
		self:send( payload )
	end

	hook.call( "shared", "onPlayerInitialSpawn", self )
end

if ( _AXIS ) then
	function player:isAuthenticated()
		return self.authenticated
	end
end

if ( _SERVER ) then
	function player:kick( message )
		require( "engine.shared.network.payload" )

		local payload = payload( "kick" )
		payload:set( "message", message )
		self.peer:send( payload:serialize() )
		self.peer:disconnect_later()
	end

	function player:onAuthenticated()
		require( "engine.shared.hook" )
		hook.call( "server", "onPlayerAuthenticated", self )
	end
end

function player:onConnect()
	require( "engine.shared.hook" )
	hook.call( "shared", "onPlayerConnect", self )
end

function player:onDisconnect()
	require( "engine.shared.hook" )
	hook.call( "shared", "onPlayerDisconnect", self )

	for i, player in ipairs( players ) do
		if ( player == self ) then
			table.remove( players, i )
			self:remove()
			return
		end
	end
end

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

function player:update( dt )
	if ( self.think and
	     self.nextThink and
	     self.nextThink <= engine.getRealTime() ) then
		self.nextThink = nil
		self:think()
	end
end

function player:__tostring()
	return "player: " .. self:getName()
end

-- Preserve the player interface
local class = player
entities.linkToClassname( player, "player" )
_G.player = class
