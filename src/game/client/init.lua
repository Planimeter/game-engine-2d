--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Game client interface
--
--============================================================================--

require( "engine.client.camera" )

local camera    = camera
local gui       = gui
local hook      = hook
local region    = region
local shader    = shader
local unrequire = unrequire
local _G        = _G

module( "game.client" )

function createDefaultPanels()
	-- Initialize speech balloons
	local hudspeechballoons = gui.hudspeechballoons( _G.g_Viewport )

	-- Initialize move indicator
	local hudmoveindicator = gui.hudmoveindicator( _G.g_Viewport )

	-- Initialize chat
	local chat = gui.hudchat( _G.g_Viewport )
	_G.g_Chat = chat

	-- Initialize game menu
	local gamemenu = gui.hudgamemenu( _G.g_Viewport )
	_G.g_GameMenu = gamemenu

	-- Initialize health
	local hudhealth = gui.hudhealth( _G.g_Viewport )
	_G.g_HudHealth = hudhealth
end

function draw()
	if ( not playerInitialized ) then
		return
	end

	-- Draw panels to worldspace
	gui.preDrawWorld()

	-- Draw world
	region.drawWorld()
end

function load( arg )
	_G.g_Viewport = gui.viewport( _G.g_RootPanel )
	_G.g_DebugOverlay = gui.debugoverlaypanel( _G.g_Viewport )
end

function onMainMenuActivate()
end

function onMainMenuClose()
end

function onPlayerChat( player, message )
	return true
end

function onReloadImage( filename )
end

function onReloadSound( filename )
end

function quit()
	_G.g_DebugOverlay:remove()
	_G.g_DebugOverlay = nil
	_G.g_Viewport:remove()
	_G.g_Viewport = nil

	unrequire( "game.client" )
	_G.gameclient = nil
end

shutdown = quit

function update( dt )
	camera.update( dt )
end
