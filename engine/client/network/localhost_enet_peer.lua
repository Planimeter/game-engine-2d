--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Localhost ENet Peer class
--
--==========================================================================--

class( "localhost_enet_peer" )

function localhost_enet_peer:localhost_enet_peer()
	g_localhost_enet_peer = self
end

function localhost_enet_peer:connect_id()
	return -1
end

function localhost_enet_peer:disconnect( data )
	local event = {
		peer = g_localhost_enet_server,
		type = "disconnect",
		data = data
	}
	engine.client.onDisconnect( event )
end

function localhost_enet_peer:disconnect_now( data )
	self:disconnect( data )
end

function localhost_enet_peer:disconnect_later( data )
	self:disconnect( data )
end

function localhost_enet_peer:index()
	return -1
end

function localhost_enet_peer:ping()
end

function localhost_enet_peer:ping_inverval( interval )
end

function localhost_enet_peer:reset()
end

function localhost_enet_peer:send( data, channel, flag )
	local event = {
		peer = g_localhost_enet_server,
		type = "receive",
		data = data
	}
	engine.client.onReceive( event )
end

function localhost_enet_peer:state()
	return "unknown"
end

function localhost_enet_peer:receive()
end

function localhost_enet_peer:round_trip_time( value )
end

function localhost_enet_peer:last_round_trip_time( value )
end

function localhost_enet_peer:throttle_configure( interval, acceleration, deceleration )
end

function localhost_enet_peer:timeout( limit, minimum, maximum )
end

function localhost_enet_peer:__tostring()
	return "127.0.0.1:" .. convar.getConvar( "host_port" ):getNumber()
end
