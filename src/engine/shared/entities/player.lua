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

function player.updatePlayers( dt )
	for i, player in ipairs( players ) do
		player:update( dt )
	end
end

function player:player()
	entity.entity( self )

	local tileSize = game.tileSize
	if ( _CLIENT ) then
		self:setLocalPosition( vector( 0, tileSize ) )
	end

	local min = vector()
	local max = vector( tileSize, -tileSize )
	self:setCollisionBounds( min, max )

	self:networkNumber( "id", player.lastPlayerId + 1 )
	self:networkNumber( "moveSpeed", 2 )

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
			local position = spawnPoint:getPosition()
			position = position + vector( 0, -_G.game.tileSize )
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
		require( "engine.shared.network.payload" )

		local payload = payload( "kick" )
		payload:set( "message", message )
		self.peer:send( payload:serialize() )
		self.peer:disconnect_later()
	end
end

function player:move()
	-- Get direction to move
	local start     = self:getPosition()
	local next      = self.path[ 1 ]
	local direction = ( next - start )
	direction:normalizeInPlace()

	-- Apply move speed to directional vector
	direction = direction * self:getNetworkVar( "moveSpeed" )

	-- Snap to pixel grid
	direction.x = math.round( direction.x )
	direction.y = math.round( direction.y )

	-- Where we'll move to
	local newPosition = start + direction

	-- Ensure we're not passing the next tile by comparing the
	-- distance traveled to the distance to the next tile
	if ( direction:length() >= ( next - start ):length() ) then
		newPosition = next
		table.remove( self.path, 1 )
	end

	-- Move
	self:setNetworkVar( "position", newPosition )

	-- We've reached our goal
	if ( #self.path == 0 ) then
		self.path = nil
	end
end

function player:moveTo( position )
	if ( position == self:getPosition() ) then
		return
	end

	if ( _CLIENT and not _SERVER ) then
		local payload = payload( "playerMove" )
		payload:set( "position", position )
		networkclient.sendToServer( payload )
	end

	if ( _SERVER ) then
		require( "engine.shared.path" )
		self.nextPath = path.getPath( self:getPosition(), position )
	end
end

if ( _SERVER ) then
	local function onPlayerMove( payload )
		local player   = payload:getPlayer()
		local position = payload:get( "position" )
		player:moveTo( position )
	end

	payload.setHandler( onPlayerMove, "playerMove" )
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
		-- process chat
		if( _SERVER ) then
			local payload = payload( "chat" )
			payload:set( "entIndex", player and player.entIndex or 0 )
			payload:set( "message", argString )

			networkserver.broadcast( payload )
		end

		game.call( "shared", "onPlayerChat", player, argString )
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

function player:update( dt )
	if ( self.think and
	     self.nextThink and
	     self.nextThink <= engine.getRealTime() ) then
		 self.nextThink = nil
		 self:think()
	end

	if ( self.nextPath ) then
		self.path = self.nextPath
		self.nextPath = nil
	end

	if ( self.path ) then
		self:move()
	end
end

function player:__tostring()
	return "player: " .. ( self:getName() or "Unnamed" )
end

-- Preserve the player interface
local class = player
entities.linkToClassname( player, "player" )
_G.player = class
