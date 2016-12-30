--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Engine server payload handlers
--
--============================================================================--

local directoryWhitelist = {
	"regions"
}

local function onDownloadRequest( payload )
	local filename = payload:get( "filename" )
	if ( not filename ) then return end
	filename   = string.fixslashes( filename )
	local peer = payload:getPeer()

	print( tostring( peer ) .. " requested \"" .. filename .. "\"..." )

	if ( string.find( filename, "/..", 1, true ) or
	     string.ispathabsolute( filename ) ) then
		print( "Access denied to " .. tostring( peer ) .. "!" )
		return
	end

	if ( not love.filesystem.exists( filename ) ) then
		print( filename .. " does not exist!" )
		return
	end

	local directory = string.match( filename, "(.-)/" )
	if ( not directory or
	     not table.hasvalue( directoryWhitelist, directory ) ) then
		print( tostring( peer ) ..
		       " requested file outside of directory whitelist (" ..
		       directory .. ")!" )
		return
	end

	engine.server.upload( filename, peer )
end

payload.setHandler( onDownloadRequest, "download" )

local function sendEntities( player )
	local entities = entity.getAll()
	for _, entity in ipairs( entities ) do
		if ( entity ~= player ) then
			local payload = payload( "entitySpawned" )
			payload:set( "classname", entity:getClassname() )
			payload:set( "entIndex", entity.entIndex )
			payload:set( "networkVars", entity:getNetworkVarTypeLenValues() )
			player:send( payload )
		end
	end
end

local function onReceiveClientInfo( payload )
	local player         = payload:getPlayer()
	local graphicsWidth  = payload:get( "graphicsWidth" )
	local graphicsHeight = payload:get( "graphicsHeight" )
	player:setGraphicsSize( graphicsWidth, graphicsHeight )
	sendEntities( player )
	player:initialSpawn()
end

payload.setHandler( onReceiveClientInfo, "clientInfo" )

local function onReceiveConcommand( payload )
	local player    = payload:getPlayer()
	local name      = payload:get( "name" )
	local argString = payload:get( "argString" )
	if ( player == localplayer ) then return end
	concommand.dispatch( player, name, argString, argTable )
end

payload.setHandler( onReceiveConcommand, "concommand" )
