--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Inventory HUD
--
--============================================================================--

class "hudinventory" ( gui.panel )

function hudinventory:hudinventory( parent )
	local name = "Inventory"
	gui.panel.panel( self, parent, "Inventory" )
	self.width  = 384
	self.height = 480

	self:invalidateLayout()
	self:setScheme( "Default" )
	self:setVisible( false )
end

local CHAT_ANIM_TIME = 0.2

function hudinventory:activate()
	if ( not self:isVisible() ) then
		self:setOpacity( 0 )
		self:animate( {
			opacity = 1
		}, CHAT_ANIM_TIME, "easeOutQuint" )
	end

	self:moveToFront()
	self:setVisible( true )
end

function hudinventory:close()
	if ( self.closing ) then
		return
	end

	self.closing = true

	self:animate( {
		opacity = 0,
	}, CHAT_ANIM_TIME, "easeOutQuint", function()
		self:setVisible( false )
		self:setOpacity( 1 )

		self.closing = nil
	end )
end

function hudinventory:draw()
	self:drawBlur()
	self:drawBackground()
	gui.panel.draw( self )
	self:drawTitle()
	self:drawForeground()
end

function hudinventory:drawBackground()
	graphics.setColor( self:getScheme( "hudinventory.backgroundColor" ) )
	graphics.rectangle( "fill", 0, 0, self:getWidth(), self:getHeight() )
end

function hudinventory:drawBlur()
	if ( not gui.blurFramebuffer ) then
		return
	end

	graphics.push()
		local x, y = self:localToScreen()
		graphics.translate( -x, -y )
		gui.blurFramebuffer:draw()
	graphics.pop()
end

function hudinventory:drawForeground()
	graphics.setColor( self:getScheme( "frame.outlineColor" ) )
	graphics.setLineWidth( 1 )
	graphics.rectangle( "line", 0, 0, self:getWidth(), self:getHeight() )
end

function hudinventory:drawTitle()
	local property = "frame.titleTextColor"
	graphics.setColor( self:getScheme( property ) )
	local font = self:getScheme( "titleFont" )
	graphics.setFont( font )
	local x = 36
	local y = x - 4
	graphics.print( string.utf8upper( self.name ), x, y )
end

function hudinventory:invalidateLayout()
	local x = graphics.getViewportWidth() - self:getWidth() - 18
	local y = graphics.getViewportHeight() - self:getHeight() - 18
	self:setPos( x, y )
	gui.panel.invalidateLayout( self )
end

function hudinventory:update( dt )
	if ( self:getOpacity() > 0 ) then
		self:invalidate()
	end

	gui.panel.update( self, dt )
end

gui.register( hudinventory, "hudinventory" )

concommand( "+inventory", "Opens the inventory", function()
	local visible = _G.g_Inventory:isVisible()
	if ( not visible ) then
		_G.g_Inventory:activate()
	end
end )

concommand( "-inventory", "Closes the inventory", function()
	local visible = _G.g_Inventory:isVisible()
	if ( visible ) then
		_G.g_Inventory:close()
	end
end )

if ( g_Inventory ) then
	local visible = g_Inventory:isVisible()
	g_Inventory:remove()
	g_Inventory = nil
	g_Inventory = gui.hudinventory( g_Viewport )
	if ( visible ) then
		g_Inventory:activate()
	end
end
