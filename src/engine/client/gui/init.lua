--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: GUI interface
--
--============================================================================--

require( "engine.client.input" )
require( "engine.client.gui.scheme" )

local getfenv      = getfenv
local graphics     = graphics
local input        = input
local ipairs       = ipairs
local math         = math
local pcall        = pcall
local print        = print
local rawget       = rawget
local require      = require
local setmetatable = setmetatable
local string       = string
local table        = table
local type         = type
local _G           = _G

local rootPanel    = g_RootPanel or nil

module( "gui" )

local hasvalue = table.hasvalue

local privateMembers = {
	"rootPanel",
	"topPanel",
	"focusedPanel"
}

local modules = {
	"engine.client",
	"game.client"
}

local find = string.find

local metatable = {
	__index = function( t, k )
		if ( not hasvalue( privateMembers, k ) ) then
			local library
			local status, err
			for i, module in ipairs( modules ) do
				library = module .. ".gui." .. k
				status, err = pcall( require, library )
				if ( status == true ) then
					break
				elseif ( status == false and
				         find( err, "module '" .. library .. "' not found:" ) ~= 1 ) then
					print( err )
				end
			end

			local v = rawget( t, k )
			if ( v ~= nil ) then return v end
		end
	end
}
setmetatable( _M, metatable )

function initialize()
	rootPanel      = rootpanel()
	_G.g_RootPanel = rootPanel

	if ( not _G._DEDICATED ) then
		_G.g_MainMenu = mainmenu()
	end

	_G.g_Console = console()
	if ( _G._DEBUG or
		hasvalue( _G.engine.getArguments(), "-console" ) ) then
		_G.g_Console:activate()
	end
end

function invalidateTree()
	rootPanel:invalidateLayout()
end

function draw()
	zIteration = 0

	rootPanel:createFramebuffer()
	rootPanel:drawFramebuffer()
end

function joystickpressed( joystick, button )
	rootPanel:joystickpressed( joystick, button )
end

function joystickreleased( joystick, button )
	rootPanel:joystickreleased( joystick, button )
end

function textinput( text )
	rootPanel:textinput( text )
end

function keypressed( key, isrepeat )
	return rootPanel:keypressed( key, isrepeat )
end

function keyreleased( key )
	return rootPanel:keyreleased( key )
end

function mousepressed( x, y, button )
	return rootPanel:mousepressed( x, y, button )
end

function mousereleased( x, y, button )
	return rootPanel:mousereleased( x, y, button )
end

function register( class, name, classname )
	_M[ name ] = class
	getfenv( 2 )[ classname or name ] = nil
end

function scale( n )
	return n * ( _G.graphics.getViewportWidth() / 1920 )
end

function setFocusedPanel( panel, focus )
	if ( focusedPanel ) then
		focusedPanel.focus = nil

		if ( focusedPanel.onLostFocus ) then
			focusedPanel:onLostFocus()
		end

		if ( focusedPanel ) then
			focusedPanel:invalidate()
		end
	end

	if ( focus ) then
		focusedPanel = panel
		if ( panel and panel.canFocus ) then
			panel.focus = focus

			if ( focusedPanel.onFocus ) then
				focusedPanel:onFocus()
			end

			panel:invalidate()
		end
	else
		focusedPanel = nil
		if ( panel ) then
			panel.focus = nil
			panel:invalidate()
		end
	end
end

function update( dt )
	if ( not input.getKeyTrap() ) then
		updateMouseOver()
	end

	rootPanel:update( dt )
end

local mx, my           = 0, 0
local panel            = nil
local getMousePosition = input.getMousePosition
local oldPanel         = nil

function updateMouseOver()
	mx, my = getMousePosition()
	panel  = rootPanel:getTopMostChildAtPos( mx, my )
	if ( panel ~= topPanel ) then
		if ( topPanel ) then
			oldPanel, topPanel = topPanel, nil
			oldPanel.mouseover = false
			oldPanel:onMouseLeave()
			oldPanel:invalidate()
		end

		topPanel = panel

		if ( topPanel ) then
			topPanel.mouseover = true
			topPanel:invalidate()
		end
	end
end
