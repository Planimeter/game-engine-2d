--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Player class
--
--==========================================================================--

require( "engine.shared.buttons" )

entities.require( "character" )

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

function player.getInOrNearMap( map )
	local t = {}
	for _, player in ipairs( player._players ) do
		local minA, maxA = player:getGraphicsBounds()

		local x, y   = map:getX(), map:getY()
		local width  = map:getPixelWidth()
		local height = map:getPixelHeight()
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
		payload:broadcast()
	end
end

function player:player()
	character.character( self )

	self:networkNumber( "id", player._lastPlayerId + 1 )
	-- 1 tile @16px * 10 in 6 seconds.
	self:networkNumber( "moveSpeed", ( 16 * 10 ) / 6 )
	-- Last processed input for each client.
	self:networkNumber( "lastCommandNumber", 0 )

	if ( _SERVER ) then
		player._lastPlayerId = self:getNetworkVar( "id" )
	end

	self._commandNumber   = 0
	self._buttons         = 0
	self._lastButtons     = 0
	self._buttonsPressed  = 0
	self._buttonsReleased = 0
	self._idle            = true

	if ( _CLIENT ) then
		require( "engine.client.sprite" )
		local sprite = sprite( "images.player" )
		sprite:setFilter( "nearest", "nearest" )
		self:setSprite( sprite )
	end

	table.insert( player._players, self )
end

if ( _CLIENT ) then
	local name = convar( "name", "Unnamed", nil, nil, "Sets your player name",
	                     nil, { "archive", "userinfo" } )

	local r_draw_network_position = convar( "r_draw_network_position", "0", nil,
	                                         nil, "Draws network position" )

	function player:draw()
		if ( r_draw_network_position:getBoolean() ) then
			if ( self._networkPosition ) then
				local position = self._networkPosition
				position       = self:worldToLocal( position )
				love.graphics.push()
					local x, y = position.x, position.y
					love.graphics.translate( x, y )
					love.graphics.setColor( color( color.white, 0.3 * 255 ) )
					entity.draw( self )
				love.graphics.pop()
			end
		end

		love.graphics.setColor( color.white )
		entity.draw( self )
	end
end

function player:keypressed( key )
end

function player:keyreleased( key )
end

local keys = {
	"forward",
	"back",
	"left",
	"right",
	"speed",
	"use"
}

-- Apply user's input to this entity.
function player:applyInput()
	for _, key in ipairs( keys ) do
		if ( self:isKeyPressed( key ) ) then
			self:keypressed( key )
		end

		if ( self:isKeyReleased( key ) ) then
			self:keyreleased( key )
		end
	end
end

function player:getName()
	return entity.getName( self ) or "Unnamed"
end

accessor( player, "graphicsWidth" )
accessor( player, "graphicsHeight" )

function player:getGraphicsBounds()
	local width  = self:getGraphicsWidth()  or 0
	local height = self:getGraphicsHeight() or 0
	width        = width  / 2
	height       = height / 2
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

local buttonKeys = {
	forward = _E.IN_FORWARD,
	back    = _E.IN_BACK,
	left    = _E.IN_LEFT,
	right   = _E.IN_RIGHT,
	speed   = _E.IN_SPEED,
	use     = _E.IN_USE
}

local function isKeySet( self, key, ... )
	local buttons = { ... }
	for _, button in ipairs( buttons ) do
		button = buttonKeys[ button ]
		local set = bit.band( self[ key ], button ) ~= 0
		if ( set ) then
			return true
		end
	end

	return false
end

function player:isKeyDown( ... )
	return isKeySet( self, "_buttons", ... )
end

function player:isKeyPressed( ... )
	return isKeySet( self, "_buttonsPressed", ... )
end

function player:isKeyReleased( ... )
	return isKeySet( self, "_buttonsReleased", ... )
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

concommand( "+speed", "Start sprinting", function( _, player )
	player._buttons = bit.bor( player._buttons, _E.IN_SPEED )
end, { "game" } )

concommand( "-speed", "Stop sprinting", function( _, player )
	player._buttons = bit.band( player._buttons, bit.bnot( _E.IN_SPEED ) )
end, { "game" } )

concommand( "+use", "Start using an entity", function( _, player )
	player._buttons = bit.bor( player._buttons, _E.IN_USE )
end, { "game" } )

concommand( "-use", "Stop using an entity", function( _, player )
	player._buttons = bit.band( player._buttons, bit.bnot( _E.IN_USE ) )
end, { "game" } )

if ( _CLIENT ) then
	function player:isPredictedPosition( v )
		if ( self ~= localplayer ) then
			return false
		end

		if ( self._predictionBuffer == nil ) then
			return false
		end

		local k = nil
		local u = nil
		for i, w in ipairs( self._predictionBuffer ) do
			if ( v == w ) then
				k = i
			elseif ( v:approximately( w ) ) then
				k = i
			elseif ( u and math.pointonlinesegment(
				     u.x, u.y,
				     w.x, w.y,
				     v.x, v.y
			) ) then
				k = i - 1
			end
			u = w
		end

		if ( k ~= nil ) then
			return k
		end

		return false
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
end

if ( _SERVER ) then
	local function onPlayerMove( payload )
		local player   = payload:getPlayer()
		local position = payload:get( "position" )
		player:removeTasks()
		player:moveTo( position )
	end

	payload.setHandler( onPlayerMove, "playerMove" )
end

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
	                             "Plays footstep sounds for players", nil,
	                             { "archive" } )

	function player:onAnimationEvent( instance, event )
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

local r_draw_prediction_buffer = nil

if ( _CLIENT ) then
	r_draw_prediction_buffer = convar( "r_draw_prediction_buffer", "0", nil,
	                                   nil, "Draws prediction buffer" )

	function player:onNetworkVarReceived( k, v )
		if ( self ~= localplayer ) then
			return
		end

		if ( k == "position" ) then
			-- Track last known network position
			if ( self._networkPosition == nil ) then
				self._networkPosition = vector.copy( self:getPosition() )
			end

			-- Draw diff
			if ( r_draw_prediction_buffer:getBoolean() ) then
				local oldPos = self._networkPosition
				local newPos = v
				require( "engine.client.debugoverlay" )
				if ( oldPos ) then
					local i = self:getNetworkVar( "worldIndex" )
					local x = newPos.x - oldPos.x
					local y = newPos.y - oldPos.y
					debugoverlay.line(
						i,
						oldPos.x + 0.5, oldPos.y - 0.5 + 1,
						{ 0, 0, x, y }, color.server, 30
					)
				end
			end

			-- Update last known network position
			self._networkPosition.x = v.x
			self._networkPosition.y = v.y

			-- Prevent rubberbanding.
			local i = self:isPredictedPosition( v )

			-- This position was predicted, so dequeue from
			-- the prediction buffer.
			if ( i ~= false ) then
				table.remove( self._predictionBuffer, 1 )
				return false
			else
				-- We didn't predict this. The buffer
				-- is now invalid.
				if ( self._predictionBuffer ) then
					table.clear( self._predictionBuffer )
				end
			end
		end
	end
end

function player:onPostWorldUpdate( timestep )
	if ( _CLIENT and not _SERVER ) then
		if ( self ~= localplayer ) then
			return
		end

		self:updatePredictionBuffer()
	end
end

if ( _SERVER ) then
	local function onPlayerUse( payload )
		local entity    = payload:get( "entity" )
		local activator = payload:getPlayer()
		local value     = payload:get( "value" )

		local canUse = game.call(
			"server", "onPlayerUse", activator, entity, value
		)
		if ( canUse == false ) then
			return
		end

		entity:use( activator, value )
	end

	payload.setHandler( onPlayerUse, "playerUse" )
end

local move  = {
	forward = vector(  0, -1 ),
	back    = vector(  0,  1 ),
	left    = vector( -1,  0 ),
	right   = vector(  1,  0 )
}

local cl_predict = convar( "cl_predict", "1", nil, nil,
                           "Perform client-side prediction", updatePrediction )

-- Get inputs and send them to the server.
-- If enabled, do client-side prediction.
local function processInputs( self, dt )
	-- Package player's input.
	local movement = vector()
	if ( self:isKeyDown( "forward" ) ) then
		movement = movement + move[ "forward" ]
	end

	if ( self:isKeyDown( "back" ) ) then
		movement = movement + move[ "back" ]
	end

	if ( self:isKeyDown( "left" ) ) then
		movement = movement + move[ "left" ]
	end

	if ( self:isKeyDown( "right" ) ) then
		movement = movement + move[ "right" ]
	end

	movement:normalizeInPlace()

	if ( self:isKeyDown( "speed" ) ) then
		movement = 2 * movement
	end

	-- Send the input to the server.
	local sendToServer  = false
	local payload       = payload( "usercmd" )
	local commandNumber = self._commandNumber + 1
	payload:set( "commandNumber", self._commandNumber )

	-- Send move data if moving, or if we haven't been
	-- idle, and need to send idle data to the server.
	local moving = movement ~= vector.origin
	if ( moving or ( not moving and not self._idle ) ) then
		payload:set( "move", movement )
		sendToServer = true
	end

	if ( self._buttons ~= 0 ) then
		payload:set( "buttons", self._buttons )
		sendToServer = true
	end

	if ( sendToServer ) then
		if ( _CLIENT and not _SERVER ) then
			self._commandNumber = commandNumber
		end

		payload:sendToServer()
	end

	-- Do client-side prediction.
	if ( cl_predict:getBoolean() ) then
		self:applyInput()
	end

	return sendToServer and movement or nil
end

function player:tick( timestep )
	local movement = nil
	local buttons  = self._buttons

	if ( _CLIENT and self == localplayer ) then
		-- Process inputs.
		movement = processInputs( self, timestep )
	end

	if ( _SERVER ) then
		if ( self._userCmds and #self._userCmds > 0 ) then
			local payload = self._userCmds[ 1 ]
			movement      = payload:get( "move" )
			buttons       = payload:get( "buttons" )
			self._commandNumber = self._commandNumber + 1
			self:setNetworkVar( "lastCommandNumber", self._commandNumber )
			table.remove( self._userCmds, 1 )
		else
			movement = vector()
		end
	end

	-- Get button states
	if ( buttons ) then
		self:updateButtonState( buttons )
	end

	-- Let the game do the movement.
	if ( movement ) then
		self:updateAnimation( timestep, movement )
		self:updateMovement( timestep, movement )
		self._idle = movement == vector.origin or nil
	end

	-- Copy output
	if ( buttons ) then
		self._lastButtons = buttons
	end

	character.tick( self, timestep )
end

if ( _SERVER ) then
	local function onUserCmd( payload )
		-- Process all pending messages from clients.
		local player     = payload:getPlayer()
		player._userCmds = player._userCmds or {}
		table.insert( player._userCmds, payload )
	end

	payload.setHandler( onUserCmd, "usercmd" )
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
		payload:broadcast()
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

	local body = self:getBody()
	if ( body ) then
		body:setMass( 89.76593 )
	end

	game.call( "shared", "onPlayerSpawn", self )
end

function player:updateAnimation( timestep, movement )
end

function player:updateButtonState( buttons )
	self._buttons         = buttons
	local buttonsChanged  = bit.bxor( self._lastButtons, self._buttons )

	self._buttonsPressed  = bit.band( buttonsChanged, buttons )
	self._buttonsReleased = bit.band( buttonsChanged, self._lastButtons )
end

local directions = {
	north     = vector(  0, -1 ),
	east      = vector(  1,  0 ),
	south     = vector(  0,  1 ),
	west      = vector( -1,  0 ),
	northeast = vector(  1, -1 ):normalize(),
	southeast = vector(  1,  1 ):normalize(),
	southwest = vector( -1,  1 ):normalize(),
	northwest = vector( -1, -1 ):normalize()
}

function player:updateMovement( timestep, movement )
	if ( _CLIENT and not _SERVER ) then
		if ( self == localplayer and not cl_predict:getBoolean() ) then
			return
		end
	end

	if ( movement ~= vector.origin ) then
		-- Moving.
		if ( _CLIENT ) then
			if ( self == localplayer ) then
				-- camera.resetZoom()
			end
		end

		-- TODO: Set animation based on velocity, instead.
		for direction, v in pairs( directions ) do
			if ( movement:normalize() == v ) then
				self:setAnimation( "walk" .. direction )
				self._lastDirection = direction
			end
		end

		local moveSpeed = self:getNetworkVar( "moveSpeed" )
		movement = moveSpeed * movement

		local body = self:getBody()
		if ( body ) then
			-- Convert pixels to meters
			movement = movement / love.physics.getMeter()

			-- Uniform acceleration
			-- v = u + at
			if ( body:getType() == "dynamic" ) then
				-- Initial velocity
				local u = vector( body:getLinearVelocity() )
				u = u / love.physics.getMeter()

				-- Synchronize timestep
				-- local m = ( 1 / 60 ) / timestep
				-- local h = m * timestep
				local h = timestep

				-- Revert linear damping
				local sv_friction = convar.getConvar( "sv_friction" )
				u = u / ( 1.0 + h * sv_friction:getNumber() )

				-- Acceleration
				local a = ( movement - u ) / h

				-- F = m * a
				movement = body:getMass() * a

				-- Negate damping
				movement = movement * ( 1.0 + h * sv_friction:getNumber() )
			end

			-- Convert meters to pixels
			movement = movement * love.physics.getMeter()

			if ( body:getType() == "kinematic" ) then
				body:setLinearVelocity( movement.x, movement.y )
			end

			if ( body:getType() == "dynamic" ) then
				body:applyForce( movement.x, movement.y )
			end
		else
			local position = self:getPosition()
			self:setPosition( position + timestep * movement )
		end
	else
		-- Idle.
		-- TODO: Set animation based on velocity, instead.
		local lastDirection = self._lastDirection
		if ( lastDirection ) then
			self:setAnimation( "idle" .. lastDirection )
			self._lastDirection = nil
		end

		local body = self:getBody()
		if ( body == nil ) then
			return
		end

		if ( body:getType() == "kinematic" ) then
			body:setLinearVelocity( 0, 0 )
		end

		if ( body:getType() == "dynamic" ) then
			local vx, vy = body:getLinearVelocity()
			body:applyLinearImpulse(
				body:getMass() * -vx,
				body:getMass() * -vy
			)
		end
	end
end

if ( _CLIENT ) then
	function player:updatePredictionBuffer()
		-- Only store to the prediction buffer if predicting
		if ( not cl_predict:getBoolean() ) then
			if ( self._predictionBuffer ) then
				self._predictionBuffer = nil
			end
			return
		end

		-- Inititalize prediction buffer
		self._predictionBuffer = self._predictionBuffer or {}

		-- Store last position
		local buffer = self._predictionBuffer
		local oldPos = buffer[ #buffer ]
		local newPos = self:getPosition()
		if ( newPos ~= oldPos ) then
			newPos = vector.copy( newPos )
			table.insert( buffer, newPos )
		end

		-- Draw the buffer
		if ( r_draw_prediction_buffer:getBoolean() ) then
			require( "engine.client.debugoverlay" )
			if ( oldPos ) then
				local i = self:getNetworkVar( "worldIndex" )
				local x = newPos.x - oldPos.x
				local y = newPos.y - oldPos.y
				debugoverlay.line(
					i,
					oldPos.x + 0.5, oldPos.y - 0.5,
					{ 0, 0, x, y }, color.client, 30
				)
			end
		end
	end
end

function player:__tostring()
	return "player: " .. self:getName()
end
