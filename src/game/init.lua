--========= Copyright © 2013-2014, Planimeter, All rights reserved. ==========--
--
-- Purpose:
--
--============================================================================--

_VADVENTURE = true

local _G = _G

module( "game" )

appSecret = ""

function conf( c )
	c.title = "Vertex Adventure"
	c.author = "Planimeter"
	return c
end

function getStartingRegion()
	return "allorova"
end

function usesAxisSavedGames()
	return true
end
