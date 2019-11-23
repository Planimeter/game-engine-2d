--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Root Panel class
--
--==========================================================================--

require( "engine.client.gui.box" )

class "gui.rootpanel" ( "gui.box" )

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
	self:setUseFullscreenCanvas( true )
end

function rootpanel:invalidateLayout()
	self:setDimensions( love.graphics.getWidth(), love.graphics.getHeight() )

	gui.panel.invalidateLayout( self )
end
