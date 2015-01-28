--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Viewport Panel class
--
--============================================================================--

class "viewport" ( gui.panel )

function viewport:viewport()
	gui.panel.panel( self )
	self.width  = graphics.getViewportWidth()
	self.height = graphics.getViewportHeight()
	self:setUseFullscreenFramebuffer( true )
	self:moveToBack()
end

function viewport:invalidateLayout()
	self:setSize( graphics.getViewportWidth(), graphics.getViewportHeight() )

	gui.panel.invalidateLayout( self )
end

local function hideViewport()
	if ( not g_Viewport ) then
		return
	end

	g_Viewport:setVisible( false )
end

hook.set( "client",              hideViewport,
          "onMainMenuActivate", "hideViewport" )

local function showViewport()
	if ( not g_Viewport ) then
		return
	end

	g_Viewport:setVisible( true )
end

hook.set( "client",           showViewport,
          "onMainMenuClose", "showViewport" )

gui.register( viewport, "viewport" )
