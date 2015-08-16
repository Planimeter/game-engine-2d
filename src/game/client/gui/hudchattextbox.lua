--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Chat Textbox HUD
--
--============================================================================--

class "hudchattextbox" ( gui.textbox )

function hudchattextbox:hudchattextbox( parent, name )
	gui.textbox.textbox( self, parent, name, "" )
	self.hudchat = parent

	self:setEditable( false )
	self:setMultiline( true )
	self:setScheme( "Chat" )

	self.borderOpacity = 0
end

function hudchattextbox:drawForeground()
	local property = "textbox.outlineColor"
	local width    = self:getWidth()
	local height   = self:getHeight()
	local color    = color( self:getScheme( property ) )
	color.a        = color.a * self.borderOpacity
	graphics.setColor( color )
	graphics.setLineWidth( 1 )
	graphics.rectangle( "line", 0, 0, width, height )
end

function hudchattextbox:getHudChat()
	return self.hudchat
end

function hudchattextbox:invalidateLayout()
	local parent = self:getHudChat()
	self:setWidth( parent:getWidth() - 2 * 36 )
	self:setHeight( parent:getHeight() - 46 - 9 - 2 * 36 )

	gui.panel.invalidateLayout( self )
end

function hudchattextbox:setHideTime( duration )
	self.hideTime = duration
end

gui.register( hudchattextbox, "hudchattextbox" )
