--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Input interface
--
--============================================================================--

local love = love

module( "input" )

function getKeyTrap()
	return _keyTrap
end

local mx, my = 0, 0

function setKeyTrap( callback )
	_keyTrap = callback
	mx, my = love.mouse.getPosition()
end

function isKeyTrapped( key )
	local callback = getKeyTrap()
	if ( callback ) then
		love.mouse.setPosition( mx, my )
		setKeyTrap()
		return callback( key )
	else
		return false
	end
end
