--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Engine client handlers
--
--============================================================================--

function engineclient.load( arg )
	local c = config.getConfig()

	require( "common.color" )
	love.graphics.setBackgroundColor( unpack( color( 31, 35, 36, 255 ) ) )
	love.graphics.setDefaultFilter( "nearest", "nearest" )
	gui.initialize()

	sound.setVolume( c.sound.volume )

	if ( _DEBUG ) then
		convar.setConvar( "perf_draw_frame_rate", "1" )
		convar.setConvar( "con_enable", "1" )
	end

	bind.readBinds()
end

function engineclient.keypressed( key, scancode, isrepeat )
	require( "engine.client.input" )
	if ( input.isKeyTrapped( key ) ) then return end
	if ( gui.keypressed( key, scancode, isrepeat ) ) then return end

	-- TODO: Move to bind system!!
	local mainmenu = g_MainMenu
	if ( key == "escape" and mainmenu and engineclient.isConnected() ) then
		if ( mainmenu:isVisible() ) then
			mainmenu:close()
		else
			mainmenu:activate()
		end
	end

	bind.keypressed( key, scancode, isrepeat )
end

function engineclient.keyreleased( key, scancode )
	if ( gui.keyreleased( key, scancode ) ) then return end
	bind.keyreleased( key, scancode )
end

function engineclient.textinput( t )
	gui.textinput( t )
end

function engineclient.textedited( text, start, length )
	gui.textedited( text, start, length )
end

function engineclient.mousepressed( x, y, button, istouch )
	require( "engine.client.input" )
	if ( input.isKeyTrapped( button ) ) then return end
	if ( gui.mousepressed( x, y, button, istouch ) ) then return end
	if ( g_MainMenu:isVisible() ) then return end
	bind.mousepressed( x, y, button, istouch )
end

function engineclient.mousereleased( x, y, button, istouch )
	if ( gui.mousereleased( x, y, button, istouch ) ) then return end
	bind.mousereleased( x, y, button, istouch )
end

local mx, my = 0, 0
local button = nil

function engineclient.wheelmoved( x, y )
	require( "engine.client.input" )
	mx, my = love.mouse.getPosition()
	button = nil
	if ( y < 0 ) then
		button = "wd"
	elseif ( y > 0 ) then
		button = "wu"
	end

	require( "engine.client.input" )
	if ( input.isKeyTrapped( button ) ) then return end
	if ( gui.wheelmoved( x, y ) ) then return end
	if ( g_MainMenu:isVisible() ) then return end

	bind.mousepressed( mx, my, button, false )
end

local updateDesktopSound = function( f )
	local snd_desktop = convar.getConvar( "snd_desktop" )
	if ( snd_desktop:getBoolean() ) then return end

	if ( not f ) then
		sound.setVolume( 0 )
	else
		local snd_volume = convar.getConvar( "snd_volume" )
		sound.setVolume( snd_volume:getNumber() )
	end
end

function engineclient.focus( f )
	updateDesktopSound( f )
end

function engineclient.quit()
end

function engineclient.resize( w, h )
	framebuffer.invalidateFramebuffers()
	gui.invalidateTree()
end

function engineclient.update( dt )
	if ( gameclient ) then gameclient.update( dt ) end
	if ( engineclient.network ) then engineclient.network.update( dt ) end
end

local perf_draw_frame_rate = convar( "perf_draw_frame_rate", "0", nil, nil,
                                     "Draws the frame rate" )

local function drawFrameRate()
	local font   = scheme.getProperty( "Default", "font" )
	love.graphics.setFont( font )
	local time   = love.timer.getFPS() .. " FPS / " ..
	               string.format( "%.3f", 1000 * love.timer.getAverageDelta() ) .. " ms"
	local width  = love.graphics.getWidth()
	local height = love.graphics.getHeight()
	local margin = gui.scale( 96 )
	local x      = width  - font:getWidth( time ) - margin
	local y      = height - font:getHeight()      - margin + point( 1 )
	local color  = scheme.getProperty( "Default", "mainmenubutton.dark.textColor" )
	graphics.setColor( color )
	graphics.print( time, x, y - point( 1 ) )
end

local r_draw_grid = convar( "r_draw_grid", "0", nil, nil,
                            "Draws a grid overlay" )
local r_focus     = convar( "r_focus", "0", nil, nil,
                            "Draw only when the engine has focus" )

function engineclient.draw()
	if ( r_focus:getBoolean() and not love.window.hasFocus() ) then
		return
	end

	if ( engineclient.isInGame() ) then
		if ( not gui.viewportFramebuffer ) then
			gui.viewportFramebuffer = graphics.newFullscreenFramebuffer()
		end

		local viewportFramebuffer = gui.viewportFramebuffer
		viewportFramebuffer:clear()
		viewportFramebuffer:renderTo( _G.gameclient.draw )
		viewportFramebuffer:draw()

		if ( r_draw_grid:getBoolean() ) then
			graphics.drawGrid()
		end
	else
		graphics.drawGrid()
	end

	gui.draw()

	if ( perf_draw_frame_rate:getBoolean() ) then
		drawFrameRate()
	end
end
