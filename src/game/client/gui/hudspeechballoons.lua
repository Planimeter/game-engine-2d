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

	self:addChatHook()
end

function hudspeechballoons:addChatHook()
end

function hudspeechballoons:removeChatHook()
end

function hudspeechballoons:draw()
	if ( not self:isVisible() ) then
		return
	end

	gui.panel.draw( self )
end

function hudspeechballoons:invalidateLayout()
	self:setWidth( graphics.getViewportWidth() )
	self:setHeight( graphics.getViewportHeight() )

	gui.panel.invalidateLayout( self )
end

function hudspeechballoons:onRemove()
	self:removeChatHook()
	gui.panel.onRemove( self )
end

gui.register( hudspeechballoons, "hudspeechballoons" )
