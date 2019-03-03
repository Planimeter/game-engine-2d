--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Net Graph class
--
--==========================================================================--

class "gui.netgraph" ( "gui.box" )

local netgraph = gui.netgraph

function netgraph:netgraph( parent, name )
	gui.box.box( self, parent, name )
	self:setDisplay( "block" )
	self:setPosition( "absolute" )

	self.font   = self:getScheme( "font" )
	self.width  = 216
	self.height = 3 * self.font:getHeight()
	self:invalidateLayout()
end

function netgraph:update( dt )
	-- HACKHACK: Fade this out for readability.
	if ( ( g_MainMenu and not g_MainMenu:isVisible() ) and
	     ( g_GameMenu and g_GameMenu:isVisible() ) ) then
		self:setOpacity( 1 - g_GameMenu:getOpacity() )
	else
		self:setOpacity( 1 )
	end

	self:invalidate()
end

function netgraph:draw()
	self:drawSentReceived()

	gui.box.draw( self )
end

function netgraph:drawSentReceived()
	if ( not engine.client.isInGame() ) then
		return
	end

	love.graphics.setColor( self:getScheme( "label.textColor" ) )

	local font = self:getFont()
	love.graphics.setFont( font )
	local text = ""

	local network = engine.client.network

	if ( _SERVER ) then
		network = engine.server.network
	end

	-- Ping
	if ( not _SERVER ) then
		local ping = network._server:round_trip_time()
		text = text .. "Ping: " .. ping .. " ms\n"
	else
		text = text .. "\n"
	end

	-- Send
	local sent = network.getAverageSentData() or 0
	local rate = "B/s"
	if ( sent >= 1024 ) then
		sent = sent / 1024
		sent = string.format( "%.2f", sent )
		rate = "kB/s"
	end
	text = text .. "Data sent/sec: " .. sent .. " " .. rate .. "\n"

	-- Receive
	local received = network.getAverageReceivedData() or 0
	local rate = "B/s"
	if ( received >= 1024 ) then
		received = received / 1024
		received = string.format( "%.2f", received )
		rate = "kB/s"
	end

	text = text .. "Data received/sec: " .. received .. " " .. rate
	local limit = self:getWidth()
	local align = "right"
	love.graphics.printf( text, 0, 0, limit, align )
end

accessor( netgraph, "font" )

function netgraph:invalidateLayout()
	local parent = self:getParent()
	local margin = gui.scale( 96 )
	local width  = self:getWidth()
	local height = self:getHeight()
	local x      = parent:getWidth()  - margin - width
	local y      = parent:getHeight() - margin - height - self.font:getHeight()
	self:setPos( x, y )

	gui.panel.invalidateLayout( self )
end
