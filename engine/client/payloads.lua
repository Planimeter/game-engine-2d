--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: Engine client payload handlers
--
--==========================================================================--

local function onReceivePlayerInitialized( payload )
	localplayer = player.getById( payload:get( "id" ) )

	g_MainMenu:close()

	require( "engine.client.camera" )
	camera.setParentEntity( localplayer )
	camera.setZoom( 2 )

	if ( not _SERVER ) then
		localplayer:initialSpawn()
	end
end

payload.setHandler( onReceivePlayerInitialized, "playerInitialized" )

local function onReceiveServerInfo( payload )
	local mapName = payload:get( "map" )

	require( "engine.shared.map" )
	if ( not map.exists( mapName ) ) then
		engine.client.download( "maps/" .. mapName .. ".lua" )
	else
		map.load( mapName )

		require( "game" )
		require( "game.client" )
		game.client.load( args )

		engine.client.sendClientInfo()
	end
end

payload.setHandler( onReceiveServerInfo, "serverInfo" )
