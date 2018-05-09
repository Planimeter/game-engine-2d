--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose:
--
--==========================================================================--

require( "engine.shared.hook" )

_VADVENTURE       = true

local game        = game or {}
_G.game           = game

local hook        = hook
local _CLIENT     = _CLIENT
local _SERVER     = _SERVER
local _VADVENTURE = _VADVENTURE
local _G          = _G

module( "game" )

tileSize      = 16
initialRegion = "test_01"

function conf( c )
	c.title  = "Vertex Adventure"
	c.author = "Planimeter"
	return c
end

function call( universe, event, ... )
	local interface = game[ universe ]
	if ( universe == "shared" ) then
		interface = game
	end

	local values = { hook.call( universe, event, ... ) }
	if ( #values > 0 ) then
		return unpack( values )
	end

	return interface[ event ]( ... )
end

function onAddonMounted( addon )
end

function onAddonUnmounted( addon )
end

function onNPCSpawn( npc )
end

function onPlayerConnect( player )
end

function onPlayerDisconnect( player )
end

if ( _VADVENTURE ) then
	function onPlayerGainedExperience( player, stat, xp )
	end

	function onPlayerGotItem( player, item, count )
	end
end

function onPlayerInitialSpawn( player )
	if ( _CLIENT ) then
		game.client.createDefaultPanels()
	end
end

if ( _VADVENTURE ) then
	function onPlayerLeveledUp( player, stat, level )
	end
end

function onPlayerSpawn( player )
end

function onReloadScript( modname )
end
