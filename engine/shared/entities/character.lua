--=========== Copyright © 2017, Planimeter, All rights reserved. ===========--
--
-- Purpose: Character class
--
--==========================================================================--

entities.requireEntity( "entity" )

class "character" ( "entity" )

function character:character()
	entity.entity( self )
end

function character:addTask( task, name )
	if ( self.tasks == nil ) then
		self.tasks = {}
	end

	table.insert( self.tasks, {
		task = task,
		name = name
	} )
end

function character:move()
	if ( self.path == nil ) then
		return
	end

	-- Get direction to move
	local start     = self:getPosition()
	local next      = self.path[ 1 ]
	local direction = ( next - start )
	direction:normalizeInPlace()

	-- Start animating
	self:updateAnimation( direction )

	-- Apply move speed to directional vector
	direction = direction * math.round( self:getNetworkVar( "moveSpeed" ) )

	-- Snap to pixel grid
	direction.x = math.round( direction.x )
	direction.y = math.round( direction.y )

	-- Where we'll move to
	local newPosition = start + direction

	-- If we change direction, don't apply linear impulse
	local applyLinearImpulse = true

	-- Ensure we're not passing the next tile by comparing the
	-- distance traveled to the distance to the next tile
	if ( direction:length() >= ( next - start ):length() ) then
		newPosition = next
		table.remove( self.path, 1 )

		self:onMoveTo( newPosition )

		if ( self.nextPosition ) then
			local path = path.getPath( newPosition, self.nextPosition )
			if ( path ) then
				self.path = path
				applyLinearImpulse = false
			end

			self.nextPosition = nil
		end
	end

	-- Move
	local body = self:getBody()
	if ( body ) then
		if ( applyLinearImpulse ) then
			local velocity = vector( body:getLinearVelocity() )
			local delta    = direction - velocity
			local mass     = body:getMass()
			body:applyLinearImpulse( delta.x * mass, delta.y * mass )
		else
			body:setLinearVelocity( 0, 0 )
		end

		body:setPosition( newPosition.x, newPosition.y )
	end

	-- We've reached our goal
	if ( self.path and #self.path == 0 ) then
		local body = self:getBody()
		if ( body ) then
			body:setLinearVelocity( 0, 0 )
			body:setPosition( newPosition.x, newPosition.y )
		end

		self.path = nil
		self:onFinishMove()
	end
end

function character:moveTo( position, callback )
	local cl_predict = convar.getConvar( "cl_predict" )
	if ( _CLIENT and not _SERVER and not cl_predict:getBoolean() ) then
		return
	end

	local from   = self:getPosition()
	local to     = position
	local fromX  = from.x
	local fromY  = from.y
	local toX    = to.x
	local toY    = to.y
	fromX, fromY = region.snapToGrid( fromX, fromY )
	toX, toY     = region.snapToGrid( toX, toY )
	if ( fromX == toX and fromY == toY ) then
		self.moveCallback = callback
		self:onFinishMove()
		return false
	end

	self.nextPosition = position
	self.moveCallback = callback
	return true
end

function character:nextTask()
	local tasks = self.tasks
	table.remove( tasks, 1 )

	if ( #tasks == 0 ) then
		self:removeTasks()
	end
end

function character:onFinishMove()
	self:setAnimation( "idle" )

	if ( self.moveCallback ) then
		self.moveCallback()
		self.moveCallback = nil
	end
end

function character:onMoveTo( position )
end

function character:removeTasks()
	self.tasks = nil
end

function character:update( dt )
	self:updateTasks()
	self:updateMovement()

	entity.update( self, dt )
end

function character:updateAnimation( direction )
	if ( direction == vector.origin ) then
		return
	end

	local angle = math.nearestmult( math.deg( direction:toAngle() ), 45 )
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

function character:updateMovement()
	if ( self.path ) then
		self:move()
		return
	end

	if ( self.nextPosition ) then
		require( "engine.shared.path" )
		local path = path.getPath( self:getPosition(), self.nextPosition )
		if ( path ) then
			self.path = path
		end
		self.nextPosition = nil
	end
end

function character:updateTasks()
	local tasks = self.tasks
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
