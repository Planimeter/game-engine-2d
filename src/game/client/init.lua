--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Game client interface
--
--============================================================================--

require( "engine.client.camera" )
-- require( "shaders.gaussianblur" )

local camera    = camera
local gui       = gui
local hook      = hook
local region    = region
local shader    = shader
local unrequire = unrequire
local _G        = _G

module( "game.client" )

function createDefaultPanels()
	-- Initialize region title
	-- local hudregiontitle = gui.hudregiontitle( _G.g_Viewport )
	-- hudregiontitle:activate()

	-- Initialize move indicator
	local hudmoveindicator = gui.hudmoveindicator( _G.g_Viewport )

	-- Initialize chat
	-- local hudchat = gui.hudchat( _G.g_Viewport )
	-- _G.g_HudChat = hudchat
end

function draw()
	if ( not playerInitialized ) then
		return
	end

	-- if ( not blur ) then
	-- 	blur = shader.getShader( "gaussianblur" )
	-- 	blurSigma = 0
	-- end
	--
	-- if ( blurSigma > 0 ) then
	-- 	blur:draw( function()
	-- 		region.drawWorld()
	-- 		_G.entity.drawAll()
	-- 	end )
	-- else
		region.drawWorld()
		_G.entity.drawAll()
	-- end
end

function load( arg )
	-- blur = shader.getShader( "gaussianblur" )
	-- blurSigma = 0

	_G.g_Viewport = gui.viewport( _G.g_RootPanel )
	_G.g_DebugOverlay = gui.debugoverlaypanel( _G.g_Viewport )
end

function onAxisSignin()
end

function onMainMenuActivate()
	-- drawBlur = true
end

function onMainMenuClose()
	-- drawBlur = false
end

function quit()
	_G.g_DebugOverlay:remove()
	_G.g_DebugOverlay = nil
	_G.g_Viewport:remove()
	_G.g_Viewport = nil

	unrequire( "game.client" )
	_G.gameclient = nil
end

shutdown = quit

function update( dt )
	-- if ( drawBlur and blurSigma <= 18 ) then
	-- 	blurSigma = blurSigma + 3
	-- 	if ( blurSigma > 18 ) then
	-- 		blurSigma = 18
	-- 	end
	-- 	blur:set( "sigma", blurSigma )
	-- elseif ( blurSigma > 0 ) then
	-- 	blurSigma = blurSigma - 3
	-- 	if ( blurSigma < 0 ) then
	-- 		blurSigma = 0
	-- 	end
	-- 	blur:set( "sigma", blurSigma )
	-- end
end
