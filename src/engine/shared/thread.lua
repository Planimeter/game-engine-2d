--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Thread interface
--
--============================================================================--

require( "love.thread" )

local pairs	   = pairs
local print	   = print
local thread   = love.thread
local tostring = tostring

module( "thread" )

function getChannel( name )
	return thread.getChannel( name )
end

local threadChannel = thread.getChannel( "thread" )

function getThreadChannel()
	return threadChannel:pop()
end

local errorHandlers = {}

function handleError( thread, errorstr )
	local errorHandler = errorHandlers[ thread ]
	if ( errorHandler ) then
		errorHandler( thread, errorstr )
	else
		print( tostring( thread ) .. ": " .. errorstr )
	end
end

function newThread( filename, errorHandler )
	local t = thread.newThread( filename )
	if ( errorHandler ) then
		errorHandlers[ t ] = errorHandler
	end
	return t 
end

local tasks = {}

function newThreadedTask( filename, callback )
	local t		  = thread.newThread( filename )
	local channel = thread.newChannel()
	threadChannel:push( channel )
	if ( callback ) then
		tasks[ t ] = {
			channel	 = channel,
			callback = callback
		}
	end
	return t, channel
end

local function dispatchCallbacks()
	local task 
	for thread in pairs( tasks ) do
		if ( not thread:isRunning() ) then
			task = tasks[ thread ]
			task.callback( task.channel )
			tasks[ thread ] = nil
		end
	end
end

local function removeErrorHandlers()
	for thread in pairs( errorHandlers ) do
		if ( not thread:isRunning() ) then
			errorHandlers[ thread ] = nil
		end
	end
end

function update( dt )
	dispatchCallbacks()
	removeErrorHandlers()
end
