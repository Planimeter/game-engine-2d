--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: GUI handlers
--
--============================================================================--

require( "engine.client.input" )

local argv    = argv
local convar  = convar
local gui     = gui
local input   = input
local love    = love
local require = require
local _G      = _G

module( "gui" )

function load()
	_rootPanel     = _M.rootpanel()
	_G.g_RootPanel = _rootPanel

	if ( not _G._DEDICATED ) then
		_G.g_MainMenu = _M.mainmenu()
	end

	_G.g_Console = _M.console()
	if ( _G._DEBUG or argv[ "--console" ] ) then
		_G.g_Console:activate()
	end
end

local function updateBlurFramebuffer( convar )
	local enabled = convar:getBoolean()
	if ( enabled ) then
		require( "shaders.gaussianblur" )
		_blurFramebuffer = _G.shader.getShader( "gaussianblur" )
		_blurFramebuffer:set( "sigma", _G.point( 12 ) )
	else
		_blurFramebuffer = nil
	end
end

local gui_draw_blur = convar( "gui_draw_blur", "1", nil, nil,
                              "Toggles gui blur", updateBlurFramebuffer )

function draw()
	if ( _viewportFramebuffer and gui_draw_blur:getBoolean() ) then
		if ( not _blurFramebuffer ) then
			require( "shaders.gaussianblur" )
			_blurFramebuffer = _G.shader.getShader( "gaussianblur" )
			_blurFramebuffer:set( "sigma", _G.point( 12 ) )
		end

		local framebuffer = love.graphics.getCanvas()
		_blurFramebuffer:renderTo( function()
			love.graphics.clear()
			love.graphics.draw( _viewportFramebuffer )
		end )
	end

	_rootPanel:createFramebuffer()
	_rootPanel:draw()
end

function filedropped( file )
	_rootPanel:filedropped( file )
end

function keypressed( key, scancode, isrepeat )
	return _rootPanel:keypressed( key, scancode, isrepeat )
end

function keyreleased( key, scancode )
	return _rootPanel:keyreleased( key, scancode )
end

function mousepressed( x, y, button, istouch )
	return _rootPanel:mousepressed( x, y, button, istouch )
end

function mousereleased( x, y, button, istouch )
	return _rootPanel:mousereleased( x, y, button, istouch )
end

function textinput( text )
	_rootPanel:textinput( text )
end

function textedited( text, start, length )
	_rootPanel:textedited( text, start, length )
end

local function updateMouseOver()
	local mx, my = love.mouse.getPosition()
	local panel = _rootPanel:getTopMostChildAtPos( mx, my )
	if ( panel ~= _topPanel ) then
		if ( _topPanel ) then
			local oldPanel = nil
			oldPanel, _topPanel = _topPanel, nil
			oldPanel.mouseover = false
			oldPanel:onMouseLeave()
			oldPanel:invalidate()
		end

		_topPanel = panel

		if ( _topPanel ) then
			_topPanel.mouseover = true
			_topPanel:invalidate()
		end
	end
end

function update( dt )
	if ( not input.getKeyTrap() ) then
		updateMouseOver()
	end

	_rootPanel:update( dt )
end

function wheelmoved( x, y )
	return _rootPanel:wheelmoved( x, y )
end
