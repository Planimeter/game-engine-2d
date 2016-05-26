--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
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

function player.getInOrNearRegion( region )
	local t = {}
	for _, player in ipairs( players ) do
		local minA, maxA = player:getViewportBounds()

		local x, y   = region:getX(), region:getY()
		local width  = region:getPixelWidth()
		local height = region:getPixelHeight()
		local minB   = vector( x, y + height )
		local maxB   = vector( x + width, y )

		if ( math.aabbsintersect( minA, maxA, minB, maxB ) ) then
			table.insert( t, player )
		end
	end
	return #t > 0 and t or nil
end

function player.removeAll()
	table.clear( player.players )
end

if ( _SERVER ) then
	function player.sendTextAll( text )
		local payload = payload( "sayText" )
		payload:set( "text", text )
		networkserver.broadcast( payload )
	end
end

function player:player()
	character.character( self )

	self:networkNumber( "id", player.lastPlayerId + 1 )
	self:networkNumber( "moveSpeed", 0.5 )

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

function player:getName()
	return entity.getName( self ) or "Unnamed"
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
		payload:set( "player", self )
		payload:set( "id", self:getNetworkVar( "id" ) )
		self:send( payload )
	end

	game.call( "shared", "onPlayerInitialSpawn", self )
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
	local moving = character.moveTo( self, position, callback )

	if ( _CLIENT and not _SERVER ) then
		local payload = payload( "playerMove" )
		payload:set( "position", position )
		networkclient.sendToServer( payload )
	end

	if ( _CLIENT ) then
		require( "engine.client.camera" )
		if ( moving and camera.getParentEntity() == self ) then
			camera.resetZoom()
		end
	end

	return moving
end

if ( _SERVER ) then
	local function onPlayerMove( payload )
		local player   = payload:getPlayer()
		local position = payload:get( "position" )
		player.nextPosition = position
	end

	payload.setHandler( onPlayerMove, "playerMove" )
end

local in_forward = false
local in_back    = false
local in_left    = false
local in_right   = false

concommand( "+forward", "Start moving player forward", function()
	in_forward = true
end, { "game" } )

concommand( "-forward", "Stop moving player forward", function()
	in_forward = false
end, { "game" } )

concommand( "+back", "Start moving player backward", function()
	in_back = true
end, { "game" } )

concommand( "-back", "Stop moving player backward", function()
	in_back = false
end, { "game" } )

concommand( "+left", "Start moving player left", function()
	in_left = true
end, { "game" } )

concommand( "-left", "Stop moving player left", function()
	in_left = false
end, { "game" } )

concommand( "+right", "Start moving player right", function()
	in_right = true
end, { "game" } )

concommand( "-right", "Stop moving player right", function()
	in_right = false
end, { "game" } )


if ( _CLIENT ) then
	function player:onAnimationEvent( event )
		if ( event == "leftfootstep" ) then
			self:emitSound( "sounds.footsteps.grassleft" )
		elseif ( event == "rightfootstep" ) then
			self:emitSound( "sounds.footsteps.grassright" )
		end
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

local function updateMovement( self, position )
	if ( self ~= localplayer ) then
		return
	end

	if ( in_forward ) then
		localplayer:moveTo( position + vector( 0, -game.tileSize ) )
	elseif ( in_back ) then
		localplayer:moveTo( position + vector( 0,  game.tileSize ) )
	elseif ( in_left ) then
		localplayer:moveTo( position + vector( -game.tileSize, 0 ) )
	elseif ( in_right ) then
		localplayer:moveTo( position + vector(  game.tileSize, 0 ) )
	end
end

function player:onMoveTo( position )
	if ( not _CLIENT ) then
		return
	end

	updateMovement( self, position )
end

concommand( "say", "Display player message",
	function( self, player, command, argString, argTable )
		if( _SERVER ) then
			if ( not game.call( "server", "onPlayerSay", player, argString ) ) then
				return
			end

			local payload = payload( "chat" )
			payload:set( "entity", player or nil )
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

if ( _SERVER ) then
	function player:sendText( text )
		local payload = payload( "sayText" )
		payload:set( "text", text )
		self:send( payload )
	end
end

if ( _CLIENT ) then
	local function onSayText( payload )
		local text = payload:get( "text" )
		chat.addText( text )
	end

	payload.setHandler( onSayText, "sayText" )
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

	local tileSize = game.tileSize
	local min      = vector()
	local max      = vector( tileSize, -tileSize )
	self:initializePhysics( "dynamic" )
	self:setCollisionBounds( min, max )

	game.call( "shared", "onPlayerSpawn", self )
end

function player:update( dt )
	character.update( self, dt )

	if ( _CLIENT ) then
		local body = self:getBody()
		if ( not body ) then
			return
		end

		if ( ( in_forward or in_back or in_left or in_right ) and
		     ( vector( body:getLinearVelocity() ) ):lengthSqr() == 0 ) then
			updateMovement( self, self:getPosition() )
		end
	end
end

function player:__tostring()
	return "player: " .. self:getName()
end

-- Preserve the player interface
local class = player
entities.linkToClassname( player, "player" )
_G.player = class
