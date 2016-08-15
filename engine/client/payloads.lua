--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Engine client payload handlers
--
--============================================================================--

local function onReceivePlayerInitialized( payload )
	localplayer = player.getById( payload:get( "id" ) )

	g_MainMenu:close()

	require( "engine.client.camera" )
	camera.setParentEntity( localplayer )
	camera.setZoom( point( 2 ) )

	if ( not _SERVER ) then localplayer:initialSpawn() end

	gameclient.playerInitialized = true
end

payload.setHandler( onReceivePlayerInitialized, "playerInitialized" )

local function onReceiveServerInfo( payload )
	local regionName = payload:get( "region" )

	require( "engine.shared.region" )
	if ( not region.exists( regionName ) ) then
		engineclient.download( "regions/" .. regionName .. ".lua" )
	else
		region.load( regionName )

		require( "game" )

		gameclient = require( "game.client" )
		gameclient.load( args )

		engineclient.sendClientInfo()
	end
end

payload.setHandler( onReceiveServerInfo, "serverInfo" )
