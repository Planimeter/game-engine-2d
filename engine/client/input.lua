--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Input interface
--
--============================================================================--

-- These values are preserved during real-time scripting.
local keyTrap  = input and input.getKeyTrap() or nil

local keyboard = love.keyboard
local mouse    = love.mouse

module( "input" )

function getMousePosition()
	return mouse.getPosition()
end

local _keyTrap = keyTrap

function getKeyTrap()
	return _keyTrap
end

function isKeyDown( ... )
	return keyboard.isDown( ... )
end

function setKeyRepeat( repeatKeys )
	keyboard.setKeyRepeat( repeatKeys )
end

function setMousePosition( x, y )
	mouse.setPosition( x, y )
end

function setTextInput( enabled )
	keyboard.setTextInput( enabled )
end

local mx, my = 0, 0

function setKeyTrap( callback )
	_keyTrap = callback
	mx, my = getMousePosition()
end

function isKeyTrapped( key )
	local callback = getKeyTrap()
	if ( callback ) then
		setMousePosition( mx, my )
		setKeyTrap()
		return callback( key )
	else
		return false
	end
end
