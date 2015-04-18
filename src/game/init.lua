--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose:
--
--============================================================================--

_VADVENTURE        = true

local _CLIENT      = _CLIENT
local _SERVER      = _SERVER

local error        = error
local hook         = hook
local rawget       = rawget
local setmetatable = setmetatable
local type         = type
local _G           = _G

module( "game" )

local metatable = {
	__index = function( table, key )
		if ( type( table ) == "table" ) then
			local v

			local gameclient = _G.gameclient
			local gameserver = _G.gameserver

			if ( _CLIENT and gameclient ) then
				v = rawget( gameclient, key )
				if ( v ~= nil ) then return v end
			end

			if ( _SERVER and gameserver ) then
				v = rawget( gameserver, key )
				if ( v ~= nil ) then return v end
			end

			v = rawget( table, key )
			if ( v ~= nil ) then return v end
		end
	end
}
setmetatable( _M, metatable )

tileSize  = 32
appSecret = ""

function conf( c )
	c.title  = "Vertex Adventure"
	c.author = "Planimeter"
	return c
end

function call( universe, event, ... )
	local interface = _G.game[ universe ]
	if ( universe == "shared" ) then
		interface = _G.game
	end

	local values = { hook.call( universe, event, ... ) }
	if ( #values > 0 ) then
		return unpack( values )
	end

	return interface[ event ]( ... )
end

function getStartingRegion()
	return "allorova"
end

function onLoad()
end

function onPlayerConnect( player )
end

function onPlayerDisconnect( player )
end

function onPlayerInitialSpawn( player )
	if ( _CLIENT ) then
		_G.gameclient.createDefaultPanels()
	end
end

function onPlayerSpawn( player )
end

function onReload()
end

function usesAxisSavedGames()
	return true
end
