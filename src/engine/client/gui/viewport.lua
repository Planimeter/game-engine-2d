--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Viewport Panel class
--
--============================================================================--

class "viewport" ( gui.panel )

function viewport:viewport( parent )
	gui.panel.panel( self, parent, "Viewport" )
	self.width  = graphics.getViewportWidth()
	self.height = graphics.getViewportHeight()
	self:setUseFullscreenFramebuffer( true )
	self:moveToBack()
end

function viewport:invalidateLayout()
	self:setSize( graphics.getViewportWidth(), graphics.getViewportHeight() )

	gui.panel.invalidateLayout( self )
end

local VIEWPORT_ANIM_TIME = 0.2

function viewport:hide()
	self:animate( {
		opacity = 0,
	}, VIEWPORT_ANIM_TIME, "easeOutQuint", function()
		self:setVisible( false )
		self:setOpacity( 1 )
	end )
end

function viewport:show()
	if ( not self:isVisible() ) then
		self:setOpacity( 0 )
		self:animate( {
			opacity = 1
		}, VIEWPORT_ANIM_TIME, "easeOutQuint" )
	end

	self:setVisible( true )
end

local function hideViewport()
	if ( not g_Viewport ) then
		return
	end

	g_Viewport:hide()
end

hook.set( "client", hideViewport, "onMainMenuActivate", "hideViewport" )

local function showViewport()
	if ( not g_Viewport ) then
		return
	end

	g_Viewport:show()
end

hook.set( "client", showViewport, "onMainMenuClose", "showViewport" )

gui.register( viewport, "viewport" )
