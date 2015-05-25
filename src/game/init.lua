--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose:
--
--============================================================================--

_VADVENTURE        = true

local _CLIENT      = _CLIENT
local _SERVER      = _SERVER

local error        = error
local hook         = hook
local rawget       = rawget
local setmetatable = setmetatable
local type         = type
local _G           = _G

module( "game" )

tileSize  = 32
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

	return interface[ event ]( ... )
end

function getStartingRegion()
	return "allorova"
end

function onPlayerChat( player, message )
	return true
end

function onPlayerConnect( player )
end

function onPlayerDisconnect( player )
end

function onPlayerInitialSpawn( player )
	if ( _CLIENT ) then
		_G.gameclient.createDefaultPanels()
	end
end

function onPlayerSpawn( player )
end

function onReloadScript( modname )
end

function usesAxisSavedGames()
	return true
end
