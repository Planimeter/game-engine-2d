--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Character class
--
--============================================================================--

require( "engine.shared.entities" )
require( "engine.shared.entities.entity" )

class "character" ( "entity" )

function character:character()
	entity.entity( self )
end

function character:addTask( task, name )
	if ( not self.tasks ) then
		self.tasks = {}
	end

	table.insert( self.tasks, {
		task = task,
		name = name
	} )
end

function character:move()
	if ( not self.path or #self.path == 0 ) then
		return
	end

	-- Get direction to move
	local start     = self:getPosition()
	local next      = self.path[ 1 ]
	local direction = ( next - start )
	direction:normalizeInPlace()

	-- Apply move speed to directional vector
	direction = direction * math.round( self:getNetworkVar( "moveSpeed" ) )

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

		if ( self.nextPosition ) then
			self.path = path.getPath( newPosition, self.nextPosition )
			self.nextPosition = nil
		end
	end

	-- Move
	self:setNetworkVar( "position", newPosition )

	-- We've reached our goal
	if ( self.path and #self.path == 0 ) then
		self.path = nil

		if ( self.moveCallback ) then
			self.moveCallback()
			self.moveCallback = nil
		end
	end
end

local cl_predict = convar( "cl_predict", "1", nil, nil,
                           "Perform client-side prediction" )
local snapToGrid = region.snapToGrid

function character:moveTo( position, callback )
	if ( _CLIENT and not _SERVER and not cl_predict:getBoolean() ) then
		return
	end

	local from   = self:getPosition()
	local to     = position
	local fromX  = from.x
	local fromY  = from.y
	local toX    = to.x
	local toY    = to.y
	fromX, fromY = snapToGrid( fromX, fromY )
	toX, toY     = snapToGrid( toX, toY )
	if ( fromX == toX and fromY == toY ) then
		return
	end

	self.nextPosition = position
	self.moveCallback = callback
end

function character:nextTask()
	local tasks = self.tasks
	table.remove( tasks, 1 )

	if ( #tasks == 0 ) then
		self.tasks = nil
	end
end

function character:onNetworkVarChanged( networkvar )
	if ( _CLIENT and networkvar:getName() == "position" ) then
		local oldValue  = self.lastPosition or networkvar:getValue()
		entity.onNetworkVarChanged( self, networkvar )

		local value     = networkvar:getValue()
		local direction = oldValue - value
		direction:normalizeInPlace()
		self:updateAnimation( direction )
	else
		entity.onNetworkVarChanged( self, networkvar )
	end
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
	local angle = math.deg( direction:toAngle() )
	if ( angle == 90 ) then
		self:setAnimation( "walknorth" )
	elseif ( angle == 135 ) then
		self:setAnimation( "walknortheast" )
	elseif ( angle == 180 ) then
		self:setAnimation( "walkeast" )
	elseif ( angle == -135 ) then
		self:setAnimation( "walksoutheast" )
	elseif ( angle == -90 ) then
		self:setAnimation( "walksouth" )
	elseif ( angle == -45 ) then
		self:setAnimation( "walksouthwest" )
	elseif ( angle == 0 ) then
		self:setAnimation( "walkwest" )
	elseif ( angle == 45 ) then
		self:setAnimation( "walknorthwest" )
	end
end

function character:updateMovement()
	if ( self.path ) then
		self:move()
	else
		if ( self.nextPosition ) then
			require( "engine.shared.path" )
			self.path = path.getPath( self:getPosition(), self.nextPosition )
			self:move()
		else
			if ( _CLIENT ) then
				self:setAnimation( "idle" )
			end
		end
	end

	if ( _CLIENT ) then
		self.lastPosition = self:getPosition()
	end
end

function character:updateTasks()
	local tasks = self.tasks
	if ( not tasks ) then
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
