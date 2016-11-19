--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Game client interface
--
--============================================================================--

require( "engine.client.camera" )

module( "game.client" )

function createDefaultPanels()
	-- Initialize speech balloons
	local hudspeechballoons = gui.hudspeechballoons( g_Viewport )

	-- Initialize move indicator
	local hudmoveindicator = gui.hudmoveindicator( g_Viewport )

	-- Initialize chat
	local chat = gui.hudchat( g_Viewport )
	_G.g_Chat = chat

	-- Initialize game menu
	local gamemenu = gui.hudgamemenu( g_Viewport )
	_G.g_GameMenu = gamemenu

	-- Initialize health
	local hudhealth = gui.hudhealth( g_Viewport )
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
	_G.g_Viewport = gui.viewport( g_RootPanel )
	_G.g_DebugOverlay = gui.debugoverlaypanel( g_Viewport )
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
	game.client = nil
end

shutdown = quit

function update( dt )
	camera.update( dt )
end
