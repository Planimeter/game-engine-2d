--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Config interface
--
--============================================================================--

require( "engine.shared.convar" )

class( "config" )

local conf = nil

function config.load( c )
	love.filesystem.setIdentity( c.identity, c.appendidentity )
	convar.readConfig()
	config.setWindow( c )
	config.setSound( c )

	conf = c
end

local function toboolean( v )
	local n = tonumber( v )
	return n ~= nil and n ~= 0
end

function config.setWindow( c )
	local r_window_width      = convar.getConfig( "r_window_width" )
	local r_window_height     = convar.getConfig( "r_window_height" )
	local r_window_fullscreen = convar.getConfig( "r_window_fullscreen" )
	local r_window_vsync      = convar.getConfig( "r_window_vsync" )
	local r_window_borderless = convar.getConfig( "r_window_borderless" )

	if ( r_window_width ) then
		c.window.width = tonumber( r_window_width )
	end

	if ( r_window_height ) then
		c.window.height = tonumber( r_window_height )
	end

	if ( r_window_fullscreen ) then
		c.window.fullscreen = toboolean( r_window_fullscreen )
	end

	if ( r_window_vsync ) then
		c.window.vsync = toboolean( r_window_vsync )
	end

	if ( r_window_borderless ) then
		c.window.borderless = toboolean( r_window_borderless )
	end
end

function config.setSound( c )
	c.sound         = c.sound or {}
	c.sound.volume  = 1
	c.sound.desktop = true

	local snd_volume  = convar.getConfig( "snd_volume" )
	local snd_desktop = convar.getConfig( "snd_desktop" )

	if ( snd_volume ) then
		c.sound.volume = tonumber( snd_volume )
	end

	if ( snd_desktop ) then
		c.sound.desktop = toboolean( snd_desktop )
	end
end

function config.getConfig()
	return conf
end
