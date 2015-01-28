--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Input interface
--
--============================================================================--

local keyboard = love.keyboard
local mouse	   = love.mouse

module( "input" )

function getMousePosition()
	return mouse.getPosition()
end

function isKeyDown( ... )
	return keyboard.isDown( ... )
end

function setKeyRepeat( repeatKeys )
	keyboard.setKeyRepeat( repeatKeys )
end

function setTextInput( enabled )
	keyboard.setTextInput( enabled )
end
