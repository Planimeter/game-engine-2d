--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose:
--
--==========================================================================--

argv = {}
for _, v in ipairs( arg ) do argv[ v ] = true end

if ( argv[ "--debug" ] ) then
	_DEBUG = true
end

if ( argv[ "--dedicated" ] ) then
	_SERVER    = true
	_DEDICATED = true
end

if ( not _SERVER ) then
	_CLIENT = true
end

function love.conf( c )
	c.title = "Grid Engine"
	c.version = "11.1"
	if ( _DEDICATED ) then
		c.modules.keyboard = false
		c.modules.mouse = false
		c.modules.joystick = false
		c.modules.touch = false
		c.modules.image = false
		c.modules.graphics = false
		c.modules.audio = false
		c.modules.sound = false
		c.modules.system = false
		c.modules.font = false
		c.modules.window = false
		c.modules.video = false
	else
		c.window.icon = "images/icon.png"
		require( "love.system" )
		if ( love.system.getOS() == "OS X" ) then
			c.window.icon = "images/icon_osx.png"
		end
		c.window.resizable = true
	end
	c.identity = "grid"

	require( "engine.shared.loadlib" )
	require( "engine.shared.config" )
	config.load( c )
end
