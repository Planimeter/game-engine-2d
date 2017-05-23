--=========== Copyright © 2017, Planimeter, All rights reserved. ===========--
--
-- Purpose: Root Panel class
--
--==========================================================================--

require( "engine.client.gui.panel" )

class "gui.rootpanel" ( "gui.panel" )

local rootpanel = gui.rootpanel

function rootpanel:rootpanel()
	self.x        = 0
	self.y        = 0
	self.width    = love.graphics.getWidth()
	self.height   = love.graphics.getHeight()
	self.name     = "Root Panel"
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
