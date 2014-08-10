--========= Copyright © 2013-2014, Planimeter, All rights reserved. ==========--
--
-- Purpose: Root Panel class
--
--============================================================================--

class "rootpanel" ( gui.panel )

function rootpanel:rootpanel()
	self.x		  = 0
	self.y		  = 0
	self.width	  = graphics.getViewportWidth()
	self.height	  = graphics.getViewportHeight()
	self.name	  = "Root Panel"
	self.zOrder	  = -1
	self.visible  = true
	self.children = {}
	self.scale	  = 1
	self.opacity  = 1
	self:setUseFullscreenFramebuffer( true )
end

function rootpanel:invalidateLayout()
	self:setSize( graphics.getViewportWidth(), graphics.getViewportHeight() )

	gui.panel.invalidateLayout( self )
end

gui.register( rootpanel, "rootpanel" )
