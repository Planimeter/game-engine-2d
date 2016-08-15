--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Root Panel class
--
--============================================================================--

class "rootpanel" ( gui.panel )

function rootpanel:rootpanel()
	self.x        = 0
	self.y        = 0
	self.width    = love.graphics.getWidth()
	self.height   = love.graphics.getHeight()
	self.name     = "Root Panel"
	self.zOrder   = -1
	self.visible  = true
	self.children = {}
	self.scale    = 1
	self.opacity  = 1
	self:setUseFullscreenFramebuffer( true )
end

function rootpanel:invalidateLayout()
	self:setSize( love.graphics.getWidth(), love.graphics.getHeight() )

	gui.panel.invalidateLayout( self )
end

gui.register( rootpanel, "rootpanel" )
