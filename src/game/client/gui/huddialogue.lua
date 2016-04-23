--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Dialogue HUD
--
--============================================================================--

class "huddialogue" ( gui.panel )

function huddialogue:huddialogue( parent )
	gui.panel.panel( self, parent, "Dialogue" )
	self.width  = 519
	self.height = 142

	self:invalidateLayout()
	self:setScheme( "Default" )
	self:setVisible( false )
end

local DIALOGUE_ANIM_TIME = 0.2

function huddialogue:activate()
	if ( not self:isVisible() ) then
		self:setOpacity( 0 )
		self:animate( {
			opacity = 1
		}, DIALOGUE_ANIM_TIME, "easeOutQuint" )
	end

	self:moveToFront()
	self:setVisible( true )
end

function huddialogue:close()
	if ( self.closing ) then
		return
	end

	self.closing = true

	self:animate( {
		opacity = 0,
	}, DIALOGUE_ANIM_TIME, "easeOutQuint", function()
		self:setVisible( false )
		self:setOpacity( 1 )

		self.closing = nil
	end )
end

function huddialogue:draw()
	self:drawBlur()
	self:drawBackground()
	gui.panel.draw( self )
	self:drawName()
	self:drawMessage()
	self:drawForeground()
end

function huddialogue:drawBackground()
	graphics.setColor( self:getScheme( "huddialogue.backgroundColor" ) )
	graphics.rectangle( "fill", 0, 0, self:getWidth(), self:getHeight() )
end

function huddialogue:drawBlur()
	if ( not gui.blurFramebuffer ) then
		return
	end

	graphics.push()
		local x, y = self:localToScreen()
		graphics.translate( -x, -y )
		gui.blurFramebuffer:draw()
	graphics.pop()
end

function huddialogue:drawForeground()
	graphics.setColor( self:getScheme( "frame.outlineColor" ) )
	graphics.setLineWidth( 1 )
	graphics.rectangle( "line", 0, 0, self:getWidth(), self:getHeight() )
end

local utf8upper = string.utf8upper

function huddialogue:drawName()
	local property = "frame.titleTextColor"
	graphics.setColor( self:getScheme( property ) )
	local font = self:getScheme( "titleFont" )
	graphics.setFont( font )
	local entity = self:getEntity()
	local name = entity ~= nil and entity:getName() or "Name"
	local x = 36
	local y = x - 4
	graphics.print( name, x, y )
end

function huddialogue:drawMessage()
	local property = "frame.titleTextColor"
	graphics.setColor( self:getScheme( property ) )
	local font = self:getScheme( "font" )
	graphics.setFont( font )
	local x = 36
	local y = 86
	graphics.print( "test", x, y )
end

function huddialogue:invalidateLayout()
	local x = graphics.getViewportWidth() / 2 - self:getWidth() / 2
	local y = graphics.getViewportHeight() - self:getHeight() - 18
	self:setPos( x, y )
	gui.panel.invalidateLayout( self )
end

function huddialogue:getEntity()
	return self.entity
end

function huddialogue:setEntity( entity )
	self.entity = entity
end

function huddialogue:update( dt )
	if ( gui.blurFramebuffer and self:isVisible() ) then
		self:invalidate()
	end

	gui.panel.update( self, dt )
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
