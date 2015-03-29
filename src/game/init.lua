--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose:
--
--============================================================================--

_VADVENTURE   = true

local _CLIENT = _CLIENT

local error   = error
local hook    = hook
local _G      = _G

module( "game" )

appSecret = ""

function conf( c )
	c.title  = "Vertex Adventure"
	c.author = "Planimeter"
	return c
end

function call( universe, event, ... )
	local interface = _G.game[ universe ]
	if ( universe == "shared" ) then
		interface = _G.game
	end

	local values = { hook.call( universe, event, ... ) }
	if ( #values > 0 ) then
		return unpack( values )
	end

	-- TODO: Remove me.
	if ( not interface ) then
		error( "attempt to index universe \"" .. universe .. "\" (a nil value)", 2 )
	end

	if ( not interface[ event ] ) then
		error( "attempt to call callback \"" .. event .. "\" (a nil value)", 2 )
	end

	return interface[ event ]( ... )
end

function getStartingRegion()
	return "allorova"
end

function onLoad()
end

function onPlayerConnect( player )
end

function onPlayerDisconnect( player )
end

function onPlayerInitialSpawn()
	if ( _CLIENT ) then
		_G.gameclient.createDefaultPanels()
	end
end

function onReload()
end

function usesAxisSavedGames()
	return true
end
