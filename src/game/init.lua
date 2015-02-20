--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose:
--
--============================================================================--

_VADVENTURE = true

local error = error
local hook  = hook
local _G    = _G

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

	if ( not interface[ event ] ) then
		error( "attempt to call " .. universe .. " game method '" .. event .. "' " ..
		       "(a nil value)", 2 )
	end

	if ( not interface[ event ]( ... ) ) then
		return
	end

	hook.call( universe, event, ... )
end

function getStartingRegion()
	return "allorova"
end

function onLoad()
end

function onPlayerConnect()
end

function onPlayerDisconnect()
end

function onPlayerInitialSpawn()
	-- if ( _CLIENT ) then
	-- 	local regiontitle = gui.regiontitle( _G.g_Viewport )
	-- 	regiontitle:activate()
	-- end
end

function onReload()
end

function usesAxisSavedGames()
	return true
end
