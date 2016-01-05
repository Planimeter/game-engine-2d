--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Host wrapper class for ENet
--
--============================================================================--

require( "enet" )

class( "host" )

function host:host( bind_address, peer_count, channel_count, in_bandwidth, out_bandwidth )
	self._host = enet.host_create( bind_address,
	                               peer_count    or 64,
	                               channel_count or 1,
	                               in_bandwidth  or 0,
	                               out_bandwidth or 0 )
end

function host:isValid()
	return self._host ~= nil
end

function host:connect( address, channel_count, data )
	return self._host:connect( address, channel_count, data )
end

function host:service( timeout )
	if ( timeout ) then
		return self._host:service( timeout )
	else
		return self._host:service()
	end
end

function host:check_events()
	return self._host:check_events()
end

function host:compress_with_range_coder()
	return self._host:compress_with_range_coder()
end

function host:flush()
	return self._host:flush()
end

function host:broadcast( data, channel, flag )
	if ( g_localhost_enet_peer ) then
		g_localhost_enet_peer:send( data, channel, flag )
	end
	return self._host:broadcast( data, channel, flag )
end

function host:channel_limit( limit )
	return self._host:channel_limit( limit )
end

function host:bandwidth_limit( incoming, outgoing )
	return self._host:bandwidth_limit( incoming, outgoing )
end

function host:total_sent_data()
	return self._host:total_sent_data()
end

function host:total_received_data()
	return self._host:total_received_data()
end

function host:service_time()
	return self._host:service_time()
end

function host:peer_count()
	return g_localhost_enet_peer and self._host:peer_count() + 1 or
	                                 self._host:peer_count()
end

function host:get_peer( index )
	if ( g_localhost_enet_peer and index == 1 ) then
		return g_localhost_enet_peer
	end
	return g_localhost_enet_peer and self._host:get_peer( index + 1 ) or
	                                 self._host:get_peer( index )
end

function host:get_socket_address()
	return self._host:get_socket_address()
end

function host:__tostring()
	return tostring( self.__host )
end
