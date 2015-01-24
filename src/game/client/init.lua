--========= Copyright © 2013-2014, Planimeter, All rights reserved. ==========--
--
-- Purpose: Game client interface
--
--============================================================================--

require( "engine.client.camera" )

local camera    = camera
local region    = region
local unrequire = unrequire
local _G        = _G

module( "game.client" )

function draw()
	if ( not playerInitialized ) then
		return
	end

	camera.preWorldDraw()
		region.drawWorld()
	camera.postWorldDraw()

	_G.entity.drawAll()
end

function load( arg )
end

function quit()
	unrequire( "game.client" )
	_G.gameclient = nil
end

shutdown = quit

function update( dt )
end
