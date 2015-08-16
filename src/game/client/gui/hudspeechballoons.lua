--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Speech Balloons HUD
--
--============================================================================--

class "hudspeechballoons" ( gui.panel )

function hudspeechballoons:hudspeechballoons( parent )
	gui.panel.panel( self, parent, "HUD Speech Balloons" )

	self.width  = graphics.getViewportWidth()
	self.height = graphics.getViewportHeight()

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

	hook.set( "shared", addSpeechBalloon, "onPlayerChat", "addSpeechBalloon" )
end

function hudspeechballoons:removeChatHook()
	hook.remove( "shared", "onPlayerChat", "addSpeechBalloon" )
end

function hudspeechballoons:draw()
	local font = self:getScheme( "chatFont" )
	graphics.setFont( font )

	if ( self.speechBalloons ) then
		for player, balloon in pairs( self.speechBalloons ) do
			local x, y   = player:getDrawPosition()
			x, y         = camera.worldToScreen( x, y )
			local sprite = player:getSprite()
			local width  = font:getWidth( balloon.message )
			local height = font:getHeight()
			x            = x + sprite:getWidth() / 2 - width / 2
			y            = y - font:getHeight()
			-- graphics.setLineWidth( 2 )
			-- graphics.setColor( self:getScheme( "hudspeechballoons.outlineColor" ) )
			-- graphics.rectangle( "line",
			--                     x - 8 - 2,
			--                     y - 8 - 2 - 10 + 4 - 8,
			--                     width  + 16 + 4,
			--                     height + 16 + 4 )
			-- graphics.setColor( self:getScheme( "hudspeechballoons.backgroundColor" ) )
			-- graphics.rectangle( "fill", x - 8, y - 8 - 10 + 4 - 8, width + 16, height + 16 )
			graphics.setColor( self:getScheme( "hudspeechballoons.textColor" ) )
			graphics.print( balloon.message, x, y - 10 + 4 - 8 )
		end
	end

	gui.panel.draw( self )
end

function hudspeechballoons:invalidateLayout()
	self:setWidth( graphics.getViewportWidth() )
	self:setHeight( graphics.getViewportHeight() )

	gui.panel.invalidateLayout( self )
end

function hudspeechballoons:listenToChat()
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

gui.register( hudspeechballoons, "hudspeechballoons" )
