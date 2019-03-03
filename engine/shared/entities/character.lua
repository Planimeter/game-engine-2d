--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: Character class
--
--==========================================================================--

entities.require( "entity" )

class "character" ( "entity" )

function character:character()
	entity.entity( self )
end

function character:addTask( task, name )
	if ( self._tasks == nil ) then
		self._tasks = {}
	end

	table.insert( self._tasks, {
		task = task,
		name = name
	} )
end

function character:move( dt )
	if ( self._path == nil ) then
		return
	end

	-- Get direction to move
	local start     = self:getPosition()
	local next      = self._path[ 1 ]
	local direction = ( next - start )
	direction:normalizeInPlace()

	-- Apply move speed to directional vector
	local velocity = ( self:getNetworkVar( "moveSpeed" ) * dt ) * direction

	-- Where we'll move to
	local newPosition = start + velocity

	-- If we change direction, don't apply linear impulse
	local applyLinearImpulse = true

	-- Ensure we're not passing the next tile by comparing the
	-- distance traveled to the distance to the next tile
	if ( velocity:length() >= ( next - start ):length() ) then
		newPosition = next
		table.remove( self._path, 1 )

		self:onMoveTo( newPosition )

		-- If we're holding down a movement key, or we clicked-to-move,
		-- `self._nextPosition` was set
		if ( self._nextPosition ) then
			local path = path.getPath( newPosition, self._nextPosition )
			if ( path ) then
				self._path = path
				applyLinearImpulse = false
			end

			self._nextPosition = nil
		end
	end

	-- Move
	local body = self:getBody()
	if ( body and not body:isDestroyed() ) then
		if ( applyLinearImpulse ) then
			local initialVelocity = vector( body:getLinearVelocity() )
			local delta = velocity - initialVelocity
			local mass = body:getMass()
			body:applyLinearImpulse( delta.x * mass, delta.y * mass )
		else
			body:setLinearVelocity( 0, 0 )
		end

		body:setPosition( newPosition.x, newPosition.y )
	end

	-- We've reached our goal
	if ( self._path and #self._path == 0 ) then
		local body = self:getBody()
		if ( body ) then
			body:setLinearVelocity( 0, 0 )
			body:setPosition( newPosition.x, newPosition.y )
		end

		self._path = nil
		self:onFinishMove()
	end
end

function character:moveTo( position, callback )
	local cl_predict = convar.getConvar( "cl_predict" )
	if ( _CLIENT and not _SERVER and not cl_predict:getBoolean() ) then
		return
	end

	if ( self._nextPosition ) then
		return false
	end

	local from   = self:getPosition()
	local to     = position
	local fromX  = from.x
	local fromY  = from.y
	local toX    = to.x
	local toY    = to.y
	fromX, fromY = map.roundToGrid( fromX, fromY )
	toX, toY     = map.roundToGrid( toX, toY )
	if ( fromX == toX and fromY == toY ) then
		self._moveCallback = callback
		self:onFinishMove()
		return false
	end

	self._nextPosition = position
	self._moveCallback = callback
	return true
end

function character:nextTask()
	local tasks = self._tasks
	table.remove( tasks, 1 )

	if ( #tasks == 0 ) then
		self:removeTasks()
	end
end

function character:onFinishMove()
	if ( self._moveCallback ) then
		self._moveCallback()
		self._moveCallback = nil
	end
end

function character:onMoveTo( position )
end

function character:onTick( dt )
	entity.onTick( self )

	-- Don't animate if we can't calculate directional velocity
	local body = self:getBody()
	if ( body == nil or body:isDestroyed() ) then
		self._lastDirection = nil
		self._lastVelocity = nil
		return
	end

	-- Remember our last velocity for determining "idle" animation
	local currentVelocity = vector( body:getLinearVelocity() )
	local moving = currentVelocity:lengthSqr() ~= 0
	if ( moving ) then
		self._lastDirection = currentVelocity:normalize()
	end
	self._lastVelocity = currentVelocity
end

function character:removeTasks()
	self._tasks = nil
end

function character:update( dt )
	self:updateTasks()
	self:updateMovement( dt )
	self:updateAnimation()

	entity.update( self, dt )
end

function character:updateAnimation()
	local cl_predict = convar.getConvar( "cl_predict" )
	if ( _CLIENT and not _SERVER and not cl_predict:getBoolean() ) then
		return
	end

	-- Don't animate if we can't calculate directional velocity
	local body = self:getBody()
	if ( body == nil or body:isDestroyed() ) then
		return
	end

	-- Set "idle" animation if we haven't moved for two frames
	local lastVelocity = self._lastVelocity or vector.origin
	local currentVelocity = vector( body:getLinearVelocity() )
	if ( lastVelocity == vector.origin and
	     currentVelocity == vector.origin ) then
		-- Find our nearest animation direction then set it
		local direction = self._lastDirection or vector( 0, -1 )
		local angle = math.nearestmult( math.deg( direction:toAngle() ), 90 )
		if ( angle == -90 ) then
			self:setAnimation( "idlenorth" )
		elseif ( angle == 0 ) then
			self:setAnimation( "idleeast" )
		elseif ( angle == 90 ) then
			self:setAnimation( "idlesouth" )
		elseif ( angle == 180 or angle == -180 ) then
			self:setAnimation( "idlewest" )
		end
	end

	-- Find our nearest animation direction then set it
	local angle = math.nearestmult( math.deg( currentVelocity:toAngle() ), 45 )
	local moving = currentVelocity:lengthSqr() ~= 0
	if ( moving ) then
		if ( angle == -90 ) then
			self:setAnimation( "walknorth" )
		elseif ( angle == -45 ) then
			self:setAnimation( "walknortheast" )
		elseif ( angle == 0 ) then
			self:setAnimation( "walkeast" )
		elseif ( angle == 45 ) then
			self:setAnimation( "walksoutheast" )
		elseif ( angle == 90 ) then
			self:setAnimation( "walksouth" )
		elseif ( angle == 135 ) then
			self:setAnimation( "walksouthwest" )
		elseif ( angle == 180 or angle == -180 ) then
			self:setAnimation( "walkwest" )
		elseif ( angle == -135 ) then
			self:setAnimation( "walknorthwest" )
		end
	end
end

function character:updateMovement( dt )
	if ( self._path ) then
		self:move( dt )
		return
	end

	if ( self._nextPosition ) then
		require( "engine.shared.path" )
		local path = path.getPath( self:getPosition(), self._nextPosition )
		if ( path ) then
			self._path = path
		end
		self._nextPosition = nil
	end
end

function character:updateTasks()
	local tasks = self._tasks
	if ( tasks == nil ) then
		return
	end

	local task = tasks[ 1 ]
	if ( task and not task.running ) then
		task.running = true
		task.task( self, function() self:nextTask() end )
	end
end

function character:__tostring()
	return "character: " .. self.__type
end
