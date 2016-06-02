--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Dialogue HUD
--
--============================================================================--

class "huddialogue" ( gui.hudframe )

function huddialogue:huddialogue( parent )
	local name  = "Dialogue"
	gui.panel.panel( self, parent, name, name )
	self.width  = point( 519 )
	self.height = point( 142 )

	self:invalidateLayout()
end

function huddialogue:draw()
	self:drawBlur()
	self:drawBackground()
	gui.panel.draw( self )
	self:drawName()
	self:drawMessage()
	self:drawForeground()
end

local utf8upper = string.utf8upper

function huddialogue:drawName()
	local property = "frame.titleTextColor"
	graphics.setColor( self:getScheme( property ) )
	local font = self:getScheme( "titleFont" )
	graphics.setFont( font )
	local entity = self:getEntity()
	local name = entity ~= nil and entity:getName() or "Name"
	local x = point( 36 )
	local y = x - point( 4 )
	graphics.print( name, x, y )
end

function huddialogue:drawMessage()
	local property = "frame.titleTextColor"
	graphics.setColor( self:getScheme( property ) )
	local font = self:getScheme( "font" )
	graphics.setFont( font )
	local x = point( 36 )
	local y = point( 86 )
	graphics.print( "test", x, y )
end

function huddialogue:invalidateLayout()
	local x = graphics.getViewportWidth() / 2 - self:getWidth() / 2
	local y = graphics.getViewportHeight() - self:getHeight() - point( 18 )
	self:setPos( x, y )
	gui.frame.invalidateLayout( self )
end

function huddialogue:getEntity()
	return self.entity
end

function huddialogue:setEntity( entity )
	self.entity = entity
end

gui.register( huddialogue, "huddialogue" )

if ( g_Dialogue ) then
	local visible = g_Dialogue:isVisible()
	g_Dialogue:remove()
	g_Dialogue = nil
	g_Dialogue = gui.huddialogue( g_Viewport )
	if ( visible ) then
		g_Dialogue:activate()
	end
end
