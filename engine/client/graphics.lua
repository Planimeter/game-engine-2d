--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Graphics interface
--
--============================================================================--

require( "common.color" )

local class      = class
local color      = color
local concommand = concommand
local graphics   = love.graphics
local image      = love.image
local ipairs     = ipairs
local love       = love
local math       = math
local os         = os
local require    = require
local string     = string
local table      = table
local unpack     = unpack
local window     = love.window
local _G         = _G

local r_window_width      = convar( "r_window_width", 800, 800, nil,
                                    "Sets the width of the window on load" )
local r_window_height     = convar( "r_window_height", 600, 600, nil,
                                    "Sets the height of the window on load" )
local r_window_fullscreen = convar( "r_window_fullscreen", "0", nil, nil,
                                    "Toggles fullscreen mode" )
local r_window_borderless = convar( "r_window_borderless", "0", nil, nil,
                                    "Toggles borderless mode" )
local r_window_vsync      = convar( "r_window_vsync", "1", nil, nil,
                                    "Toggles vertical synchronization" )

function point( value )
	return window.toPixels( value )
end

local point = point

module( "graphics" )

local gcd = math.gcd

function getAspectRatios()
	local modes = getFullscreenModes()
	local r     = 1
	for i, mode in ipairs( modes ) do
		r = gcd( mode.width, mode.height )
		mode.x = mode.width  / r
		mode.y = mode.height / r
		mode.width  = nil
		mode.height = nil
	end
	table.sort( modes, function( a, b )
		return a.x * a.y < b.x * b.y
	end )
	modes = table.unique( modes )
	return modes
end

local mode   = nil
local w, h   = -1, -1
local r      = 1
local mx, my = -1, -1

function getFullscreenModes( x, y )
	local modes = window.getFullscreenModes()
	if ( x and y ) then
		for i = #modes, 1, -1 do
			mode = modes[ i ]
			w, h = mode.width, mode.height
			if ( w >= 800 and h >= 600 ) then
				r = gcd( w, h )
				mx = w / r
				my = h / r
				if ( not ( mx == x and my == y ) ) then
					table.remove( modes, i )
				end
			else
				table.remove( modes, i )
			end
		end
	end
	table.sort( modes, function( a, b )
		return a.width * a.height < b.width * b.height
	end )
	return modes
end

local _opacity = 1

function getOpacity()
	return _opacity
end

function getAspectRatios()
	w = graphics.getWidth()
	h = graphics.getHeight()
	r = gcd( w, h )
	return w / r, h / r
end

function newFramebuffer( width, height )
	require( "engine.client.framebuffer" )
	return _G.framebuffer( width, height )
end

function newFullscreenFramebuffer()
	require( "engine.client.framebuffer" )
	return _G.fullscreenframebuffer()
end

local floor = math.floor

function print( text, x, y, r, sx, sy, ox, oy, kx, ky, tracking )
	if ( x ) then
		x = floor( x )
	end

	if ( y ) then
		y = floor( y )
	end

	if ( tracking ) then
		local font = graphics.getFont()
		local char
		for i = 1, string.len( text ) do
			char = string.sub( text, i, i )
			graphics.print( char, x, y, r, sx, sy, ox, oy, kx, ky )
			x = x + font:getWidth( char ) + tracking
		end
		return
	end

	graphics.print( text, x, y, r, sx, sy, ox, oy, kx, ky )
end

local tempColor = color()

function setBackgroundColor( color, multiplicative )
	tempColor[ 1 ] = color[ 1 ] * ( multiplicative and _opacity or 1 )
	tempColor[ 2 ] = color[ 2 ] * ( multiplicative and _opacity or 1 )
	tempColor[ 3 ] = color[ 3 ] * ( multiplicative and _opacity or 1 )
	tempColor[ 4 ] = color[ 4 ] * _opacity
	graphics.setBackgroundColor( tempColor )
end

function setColor( color, multiplicative )
	tempColor[ 1 ] = color[ 1 ] * ( multiplicative and _opacity or 1 )
	tempColor[ 2 ] = color[ 2 ] * ( multiplicative and _opacity or 1 )
	tempColor[ 3 ] = color[ 3 ] * ( multiplicative and _opacity or 1 )
	tempColor[ 4 ] = color[ 4 ] * _opacity
	graphics.setColor( tempColor )
end

function setOpacity( opacity )
	_opacity = opacity
end
