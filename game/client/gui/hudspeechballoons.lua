--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Speech Balloons HUD
--
--============================================================================--

class "gui.hudspeechballoons" ( "gui.panel" )

local hudspeechballoons = gui.hudspeechballoons

function hudspeechballoons:hudspeechballoons( parent )
	gui.panel.panel( self, parent, "HUD Speech Balloons" )

	self.width  = love.graphics.getWidth()
	self.height = love.graphics.getHeight()

	self:setScheme( "Default" )

	self:addChatHook()
end

function hudspeechballoons:addChatHook()
	local function addSpeechBalloon( player, message )
		if ( not self.speechBalloons ) then
			self.speechBalloons = {}
		end

		self.speechBalloons[ player ] = {
			player  = player,
			message = message
		}
	end

	hook.set( "client", addSpeechBalloon, "onPlayerChat", "addSpeechBalloon" )
end

function hudspeechballoons:removeChatHook()
	hook.remove( "client", "onPlayerChat", "addSpeechBalloon" )
end

function hudspeechballoons:draw()
	local font = self:getScheme( "fontBold" )
	love.graphics.setFont( font )
	love.graphics.setColor( self:getScheme( "hudspeechballoons.textColor" ) )

	if ( self.speechBalloons ) then
		for player, balloon in pairs( self.speechBalloons ) do
			local x, y   = player:getDrawPosition()
			x, y         = camera.worldToScreen( x, y )
			local sprite = player:getSprite()
			local scale  = camera.getZoom()
			local width  = font:getWidth( balloon.message )
			local height = font:getHeight()
			x            = x + ( sprite:getWidth() * scale ) / 2 - width / 2
			y            = y - font:getHeight()
			graphics.print( balloon.message, x, y + point( -10 + 4 - 8 ) )
		end
	end

	gui.panel.draw( self )
end

function hudspeechballoons:invalidateLayout()
	self:setWidth( love.graphics.getWidth() )
	self:setHeight( love.graphics.getHeight() )

	gui.panel.invalidateLayout( self )
end

function hudspeechballoons:onRemove()
	self:removeChatHook()
	gui.panel.onRemove( self )
end

function hudspeechballoons:update( dt )
	if ( not self:isVisible() ) then
		return
	end

	self:invalidate()
end
