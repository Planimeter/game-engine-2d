--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: GUI interface
--
--============================================================================--

require( "engine.client.input" )
require( "engine.client.gui.scheme" )
require( "shaders.gaussianblur" )

local convar       = convar
local getfenv      = getfenv
local graphics     = graphics
local input        = input
local ipairs       = ipairs
local math         = math
local pcall        = pcall
local point        = point
local print        = print
local rawget       = rawget
local require      = require
local setmetatable = setmetatable
local shader       = shader
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
		if ( hasvalue( privateMembers, k ) ) then
			return
		end

		local library
		local status, err
		local message
		for i, module in ipairs( modules ) do
			library = module .. ".gui." .. k
			status, err = pcall( require, library )
			if ( status == true ) then
				break
			end

			message = "module '" .. library .. "' not found:"
			if ( status == false and find( err, message ) ~= 1 ) then
				print( err )
			end
		end

		local v = rawget( t, k )
		if ( v ~= nil ) then return v end
	end
}
setmetatable( _M, metatable )

function initialize()
	rootPanel = rootpanel()
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

local function updateBlurFramebuffer( convar )
	local enabled = convar:getBoolean()
	if ( not enabled ) then
		blurFramebuffer = nil
	else
		blurFramebuffer = shader.getShader( "gaussianblur" )
		blurFramebuffer:set( "sigma", _G.point( 12 ) )
	end
end

local gui_draw_blur = convar( "gui_draw_blur", "1", nil, nil,
                              "Toggles gui blur", updateBlurFramebuffer )

function draw()
	if ( viewportFramebuffer and gui_draw_blur:getBoolean() ) then
		if ( not blurFramebuffer ) then
			blurFramebuffer = shader.getShader( "gaussianblur" )
			blurFramebuffer:set( "sigma", _G.point( 12 ) )
		end

		blurFramebuffer:renderTo( function()
			viewportFramebuffer:draw()
		end )
	end

	rootPanel:createFramebuffer()
	rootPanel:drawFramebuffer()
end

function filedropped( file )
	rootPanel:filedropped( file )
end

function joystickpressed( joystick, button )
	rootPanel:joystickpressed( joystick, button )
end

function joystickreleased( joystick, button )
	rootPanel:joystickreleased( joystick, button )
end

function keypressed( key, scancode, isrepeat )
	return rootPanel:keypressed( key, scancode, isrepeat )
end

function keyreleased( key, scancode )
	return rootPanel:keyreleased( key, scancode )
end

function mousepressed( x, y, button, istouch )
	return rootPanel:mousepressed( x, y, button, istouch )
end

function mousereleased( x, y, button, istouch )
	return rootPanel:mousereleased( x, y, button, istouch )
end

function preDrawWorld()
	rootPanel:preDrawWorld()
end

function register( class, name )
	_M[ name ] = class
	getfenv( 2 )[ name ] = nil
end

function scale( n )
	return n * ( _G.graphics.getViewportHeight() / 1080 )
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

function textinput( text )
	rootPanel:textinput( text )
end

function textedited( text, start, length )
	rootPanel:textedited( text, start, length )
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

function wheelmoved( x, y )
	return rootPanel:wheelmoved( x, y )
end
