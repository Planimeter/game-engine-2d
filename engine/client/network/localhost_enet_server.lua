--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Localhost ENet Server class
--
--============================================================================--

class "localhost_enet_server" ( "localhost_enet_peer" )

function localhost_enet_server:localhost_enet_server()
	g_localhost_enet_server = self
end

function localhost_enet_server:disconnect( data )
	local event = {
		peer = g_localhost_enet_peer,
		type = "disconnect",
		data = data
	}
	g_localhost_enet_peer = nil
	serverengine.onDisconnect( event )
end

function localhost_enet_server:send( data, channel, flag )
	local event = {
		peer = g_localhost_enet_peer,
		type = "receive",
		data = data
	}
	serverengine.onReceive( event )
end

function localhost_enet_server:__tostring()
	return "127.0.0.1:" .. convar.getConvar( "host_port" ):getNumber()
end
