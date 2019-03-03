--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Engine client handlers
--
--==========================================================================--

local bind    = bind
local config  = config
local convar  = convar
local engine  = engine
local gui     = gui
local ipairs  = ipairs
local love    = love
local require = require
local _CLIENT = _CLIENT
local _SERVER = _SERVER
local _G      = _G

module( "engine.client" )

function load( arg )
	love.graphics.setBackgroundColor( 31 / 255, 35 / 255, 36 / 255, 1 )
	gui.load()

	local c = config.getConfig()
	love.audio.setVolume( c.sound.volume )

	if ( _G._DEBUG ) then
		convar.setConvar( "perf_draw_frame_rate", "1" )
		convar.setConvar( "con_enable", "1" )
	end

	bind.readBinds()
end

function keypressed( key, scancode, isrepeat )
	require( "engine.client.input" )
	if ( _G.input.isKeyTrapped( key ) ) then
		return
	end

	if ( gui.keypressed( key, scancode, isrepeat ) ) then
		return
	end

	-- TODO: Move to bind system!!
	local mainmenu = _G.g_MainMenu
	if ( key == "escape" and mainmenu and isConnected() ) then
		if ( mainmenu:isVisible() ) then
			mainmenu:close()
		else
			mainmenu:activate()
		end
	end

	bind.keypressed( key, scancode, isrepeat )
end

function keyreleased( key, scancode )
	if ( gui.keyreleased( key, scancode ) ) then
		return
	end

	bind.keyreleased( key, scancode )
end

function textinput( t )
	gui.textinput( t )
end

function textedited( text, start, length )
	gui.textedited( text, start, length )
end

function mousepressed( x, y, button, istouch )
	require( "engine.client.input" )
	if ( _G.input.isKeyTrapped( button ) ) then
		return
	end

	if ( gui.mousepressed( x, y, button, istouch ) ) then
		return
	end

	if ( _G.g_MainMenu:isVisible() ) then
		return
	end

	bind.mousepressed( x, y, button, istouch )
end

function mousereleased( x, y, button, istouch )
	if ( gui.mousereleased( x, y, button, istouch ) ) then
		return
	end

	bind.mousereleased( x, y, button, istouch )
end

function wheelmoved( x, y )
	local mx, my = love.mouse.getPosition()
	local button = nil
	if ( y < 0 ) then
		button = "wd"
	elseif ( y > 0 ) then
		button = "wu"
	end

	require( "engine.client.input" )
	if ( _G.input.isKeyTrapped( button ) ) then
		return
	end

	if ( gui.wheelmoved( x, y ) ) then
		return
	end

	if ( _G.g_MainMenu:isVisible() ) then
		return
	end

	bind.mousepressed( mx, my, button, false )
end

local function updateDesktopSound( focus )
	local snd_desktop = convar.getConvar( "snd_desktop" )
	if ( snd_desktop:getBoolean() ) then
		return
	end

	if ( focus ) then
		local snd_volume = convar.getConvar( "snd_volume" )
		love.audio.setVolume( snd_volume:getNumber() )
	else
		love.audio.setVolume( 0 )
	end
end

function focus( focus )
	updateDesktopSound( focus )
end

function quit()
end

function resize( w, h )
	if ( _G.canvas ) then
		_G.canvas.invalidateCanvases()
	end

	gui.invalidateTree()
end

function update( dt )
	local _CLIENT = _CLIENT
	local _SERVER = _SERVER or _G._SERVER

	if ( _CLIENT and not _SERVER ) then
		_G.map.update( dt )
	end

	local game = _G.game and _G.game.client or nil
	if ( game ) then
		game.update( dt )
	end

	local network = engine.client.network
	if ( network ) then
		network.update( dt )
	end
end

local r_focus = convar( "r_focus", "1", nil, nil,
                        "Draw only when the engine has focus" )

function draw()
	if ( r_focus:getBoolean() and not love.window.hasFocus() ) then
		return
	end

	if ( isInGame() ) then
		if ( gui._viewportFramebuffer == nil ) then
			require( "engine.client.canvas" )
			gui._viewportFramebuffer = _G.fullscreencanvas()
		end

		gui._viewportFramebuffer:renderTo( function()
			love.graphics.clear()
			_G.game.client.draw()
		end )

		love.graphics.setColor( _G.color.white )
		gui._viewportFramebuffer:draw()
	end

	gui.draw()
end
