--========= Copyright © 2013-2014, Planimeter, All rights reserved. ==========--
--
-- Purpose: Game client interface
--
--============================================================================--

require( "engine.client.camera" )

local camera	   = camera
local engineclient = engineclient
local region	   = region
local unrequire	   = unrequire
local _G		   = _G

module( "game.client" )

function draw()
	if ( playerInitialized ) then
		camera.preWorldDraw()
			region.drawWorld()
		camera.postWorldDraw()
	end
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
