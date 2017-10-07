--=========== Copyright © 2017, Planimeter, All rights reserved. ===========--
--
-- Purpose: Player class
--
--==========================================================================--

require( "engine.shared.buttons" )

entities.requireEntity( "character" )

class "player" ( "character" )

player._players      = player._players      or {}
player._lastPlayerId = player._lastPlayerId or 0

function player.initialize( peer )
	local player = _G.game.server.getPlayerClass()()
	player.peer  = peer
	return player
end

function player.getAll()
	return table.shallowcopy( player._players )
end

function player.getById( id )
	for _, player in ipairs( player._players ) do
		if ( player:getNetworkVar( "id" ) == id ) then
			return player
		end
	end
end

function player.getByPeer( peer )
	for _, player in ipairs( player._players ) do
		if ( player.peer == peer ) then
			return player
		end
	end
end

function player.getInOrNearRegion( region )
	local t = {}
	for _, player in ipairs( player._players ) do
		local minA, maxA = player:getGraphicsBounds()

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
	table.clear( player._players )
end

if ( _SERVER ) then
	function player.sendTextAll( text )
		local payload = payload( "sayText" )
		payload:set( "text", text )
		engine.server.network.broadcast( payload )
	end
end

function player:player()
	character.character( self )

	self:networkNumber( "id", player._lastPlayerId + 1 )
	self:networkNumber( "moveSpeed", 66 )

	if ( _SERVER ) then
		player._lastPlayerId = self:getNetworkVar( "id" )
	end

	self._buttons = 0

	if ( _CLIENT ) then
		require( "engine.client.sprite" )
		local sprite = sprite( "images.player" )
		self:setSprite( sprite )
	end

	table.insert( player._players, self )
end

function player:getName()
	return entity.getName( self ) or "Unnamed"
end

accessor( player, "graphicsWidth" )
accessor( player, "graphicsHeight" )

function player:getGraphicsBounds()
	local width  = self:getGraphicsWidth()  or 0
	local height = self:getGraphicsHeight() or 0
	local min    = self:localToWorld( vector( -width / 2,  height / 2 ) )
	local max    = self:localToWorld( vector(  width / 2, -height / 2 ) )
	return min, max
end

function player:getGraphicsSize()
	return self:getGraphicsWidth(), self:getGraphicsHeight()
end

function player:initialSpawn()
	if ( self._initialized ) then
		return
	else
		self._initialized = true
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

function player:isKeyDown( button )
	return bit.band( self._buttons, button ) ~= 0
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
		engine.client.network.sendToServer( payload )
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
		player._nextPosition = position
	end

	payload.setHandler( onPlayerMove, "playerMove" )
end

concommand( "+forward", "Start moving player forward", function( _, player )
	player._buttons = bit.bor( player._buttons, _E.IN_FORWARD )
end, { "game" } )

concommand( "-forward", "Stop moving player forward", function( _, player )
	player._buttons = bit.band( player._buttons, bit.bnot( _E.IN_FORWARD ) )
end, { "game" } )

concommand( "+back", "Start moving player backward", function( _, player )
	player._buttons = bit.bor( player._buttons, _E.IN_BACK )
end, { "game" } )

concommand( "-back", "Stop moving player backward", function( _, player )
	player._buttons = bit.band( player._buttons, bit.bnot( _E.IN_BACK ) )
end, { "game" } )

concommand( "+left", "Start moving player left", function( _, player )
	player._buttons = bit.bor( player._buttons, _E.IN_LEFT )
end, { "game" } )

concommand( "-left", "Stop moving player left", function( _, player )
	player._buttons = bit.band( player._buttons, bit.bnot( _E.IN_LEFT ) )
end, { "game" } )

concommand( "+right", "Start moving player right", function( _, player )
	player._buttons = bit.bor( player._buttons, _E.IN_RIGHT )
end, { "game" } )

concommand( "-right", "Stop moving player right", function( _, player )
	player._buttons = bit.band( player._buttons, bit.bnot( _E.IN_RIGHT ) )
end, { "game" } )


if ( _CLIENT ) then
	local function updateStepSound( self, event )
		if ( event ~= "leftfootstep" and
		     event ~= "rightfootstep" ) then
			return
		end

		if ( self._stepSoundTime and
		     love.timer.getTime() < self._stepSoundTime ) then
			return
		end

		if ( event == "leftfootstep" ) then
			self:emitSound( "sounds.footsteps.grassleft" )
		end

		if ( event == "rightfootstep" ) then
			self:emitSound( "sounds.footsteps.grassright" )
		end

		local sprite = self:getSprite()
		local frametime = sprite:getFrametime()
		self._stepSoundTime = love.timer.getTime() + frametime
	end

	local cl_footsteps = convar( "cl_footsteps", 0, nil, nil,
	                             "Plays footstep sounds for players" )

	function player:onAnimationEvent( event )
		if ( cl_footsteps:getBoolean() ) then
			updateStepSound( self, event )
		end
	end
end

function player:onConnect()
	game.call( "shared", "onPlayerConnect", self )
end

function player:onDisconnect()
	game.call( "shared", "onPlayerDisconnect", self )

	for i, player in ipairs( player._players ) do
		if ( player == self ) then
			table.remove( player._players, i )
			self:remove()
			return
		end
	end
end

local function updateMovement( self, position )
	if ( self ~= localplayer ) then
		return
	end

	if ( _CLIENT and not _SERVER ) then
		local payload = payload( "usercmd" )
		payload:set( "buttons", self._buttons )
		engine.client.network.sendToServer( payload )
	end

	if ( self:isKeyDown( _E.IN_FORWARD ) ) then
		localplayer:moveTo( position + vector( 0, -1 ) )
	elseif ( self:isKeyDown( _E.IN_BACK ) ) then
		localplayer:moveTo( position + vector( 0,  game.tileSize + 1 ) )
	elseif ( self:isKeyDown( _E.IN_LEFT ) ) then
		localplayer:moveTo( position + vector( -1, 0 ) )
	elseif ( self:isKeyDown( _E.IN_RIGHT ) ) then
		localplayer:moveTo( position + vector(  game.tileSize + 1, 0 ) )
	end
end

if ( _SERVER ) then
	local function onUserCmd( payload )
		local player    = payload:getPlayer()
		local buttons   = payload:get( "buttons" )
		player._buttons = buttons
		updateMovement( player, player:getPosition() )
	end

	payload.setHandler( onUserCmd, "usercmd" )
end

function player:onMoveTo( position )
	if ( _CLIENT ) then
		updateMovement( self, position )
	end
end

function player:onNetworkVarChanged( networkvar )
	if ( _CLIENT and networkvar:getName() == "health" ) then
		if ( g_HudHealth ) then
			g_HudHealth:invalidateLayout()
		end
	end

	entity.onNetworkVarChanged( self, networkvar )
end

concommand( "say", "Display player message",
	function( self, player, command, argString, argTable )
		if ( not _SERVER ) then
			return
		end

		local canSay = game.call( "server", "onPlayerSay", player, argString )
		if ( canSay == false ) then
			return
		end

		local payload = payload( "chat" )
		payload:set( "entity", player or nil )
		payload:set( "message", argString )

		engine.server.network.broadcast( payload )
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

function player:setGraphicsSize( graphicsWidth, graphicsHeight )
	self:setGraphicsWidth( graphicsWidth )
	self:setGraphicsHeight( graphicsHeight )
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
		if ( body == nil ) then
			return
		end

		if ( ( self:isKeyDown( _E.IN_FORWARD ) or
		       self:isKeyDown( _E.IN_BACK )    or
		       self:isKeyDown( _E.IN_LEFT )    or
		       self:isKeyDown( _E.IN_RIGHT ) ) and
		     ( vector( body:getLinearVelocity() ) ):lengthSqr() == 0 ) then
			updateMovement( self, self:getPosition() )
		end
	end
end

function player:__tostring()
	return "player: " .. self:getName()
end
