--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: GUI handlers
--
--==========================================================================--

require( "engine.client.input" )

local argv    = argv
local convar  = convar
local gui     = gui
local input   = input
local love    = love
local require = require
local _G      = _G

module( "gui" )

local function updateFramerate( convar )
	local enabled = convar:getBoolean()
	if ( enabled ) then
		if ( _G.g_Framerate ) then
			return
		end

		local framerate = gui.framerate( nil, "Frame Rate" )
		_G.g_Framerate = framerate
	else
		_G.g_Framerate:remove()
		_G.g_Framerate = nil
	end
end

local perf_draw_frame_rate = convar( "perf_draw_frame_rate", "0", nil, nil,
                                     "Draws the frame rate", updateFramerate )

local function updateNetGraph( convar )
	local enabled = convar:getBoolean()
	if ( enabled ) then
		if ( _G.g_NetGraph ) then
			return
		end

		local netgraph = gui.netgraph( nil, "Net Graph" )
		_G.g_NetGraph = netgraph
	else
		_G.g_NetGraph:remove()
		_G.g_NetGraph = nil
	end
end

local perf_draw_net_graph = convar( "perf_draw_net_graph", "0", nil, nil,
                                     "Draws the net graph", updateNetGraph )

function load()
	-- Initialize root panel
	_rootPanel = _M.rootpanel()
	_G.g_RootPanel = _rootPanel

	-- Initialize main menu
	if ( not _G._DEDICATED ) then
		local mainmenu = _M.mainmenu()
		_G.g_MainMenu = mainmenu
	end

	-- Initialize console
	local console = _M.console()
	_G.g_Console = console
	if ( _G._DEBUG or argv[ "--console" ] ) then
		console:activate()
	end

	if ( perf_draw_frame_rate:getBoolean() ) then
		updateFramerate( perf_draw_frame_rate )
	end

	if ( perf_draw_net_graph:getBoolean() ) then
		updateNetGraph( perf_draw_net_graph )
	end
end

local function updateTranslucencyFramebuffer( convar )
	local enabled = convar:getBoolean()
	if ( enabled ) then
		require( "shaders.gaussianblur" )
		_translucencyFramebuffer = _G.shader.getShader( "gaussianblur" )
		_translucencyFramebuffer:set( "sigma", love.window.toPixels( 20 ) )
	else
		_translucencyFramebuffer = nil
	end
end

local gui_draw_translucency = convar( "gui_draw_translucency", "1", nil, nil,
                                      "Toggles gui translucency",
                                      updateTranslucencyFramebuffer )

function draw()
	if ( _viewportFramebuffer and gui_draw_translucency:getBoolean() ) then
		if ( _translucencyFramebuffer == nil ) then
			require( "shaders.gaussianblur" )
			_translucencyFramebuffer = _G.shader.getShader( "gaussianblur" )
			_translucencyFramebuffer:set( "sigma", love.window.toPixels( 12 ) )
		end

		_translucencyFramebuffer:renderTo( function()
			love.graphics.clear()
			_viewportFramebuffer:draw()
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
	if ( panel == _topPanel ) then
		return
	end

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

function update( dt )
	if ( not input.getKeyTrap() ) then
		updateMouseOver()
	end

	_rootPanel:update( dt )
end

function wheelmoved( x, y )
	return _rootPanel:wheelmoved( x, y )
end
