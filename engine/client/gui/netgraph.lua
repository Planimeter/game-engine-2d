--=========== Copyright © 2017, Planimeter, All rights reserved. ===========--
--
-- Purpose: Net Graph class
--
--==========================================================================--

class "gui.netgraph" ( "gui.panel" )

local netgraph = gui.netgraph

function netgraph:netgraph( parent, name )
	gui.panel.panel( self, parent, name )
	self:setScheme( "Default" )
	self.font   = self:getScheme( "font" )
	self.width  = love.window.toPixels( 216 )
	self.height = 2 * self.font:getHeight()
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

	gui.panel.draw( self )
end

function netgraph:drawSentReceived()
	if ( not engine.client.isInGame() ) then
		return
	end

	love.graphics.setColor( self:getScheme( "label.textColor" ) )

	local font = self:getFont()
	love.graphics.setFont( font )

	local network = engine.client.network

	if ( _SERVER ) then
		network = engine.server.network
	end

	local sent     = network.getAverageSentData() or 0
	local received = network.getAverageReceivedData() or 0
	local text     = "Data sent/sec: " .. sent .. " kB/s\n" ..
	                 "Data received/sec: " .. received .. " kB/s"
	local limit    = self:getWidth()
	local align    = "right"
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
