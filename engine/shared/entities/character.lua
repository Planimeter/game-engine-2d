--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
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

function character:moveTo( position, callback )
	if ( callback ) then
		callback()
	end
end

function character:nextTask()
	local tasks = self._tasks
	table.remove( tasks, 1 )

	if ( #tasks == 0 ) then
		self:removeTasks()
	end
end

function character:removeTasks()
	self._tasks = nil
end

function character:tick( timestep )
	self:updateTasks()
	entity.tick( self, timestep )
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
