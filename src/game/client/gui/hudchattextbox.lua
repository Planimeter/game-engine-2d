--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Chat Textbox HUD
--
--============================================================================--

class "hudchattextbox" ( gui.textbox )

function hudchattextbox:hudchattextbox( parent, name )
	gui.textbox.textbox( self, parent, name, "" )

	self:setEditable( false )
	self:setMultiline( true )
	self:setScheme( "Chat" )
end

function hudchattextbox:draw()
	if ( not self:isVisible() ) then
		return
	end

	self:drawBackground()
	self:drawText()
	self:drawCursor()

	gui.panel.draw( self )

	self:drawForeground()
end

function hudchattextbox:drawBackground()
	local property = "textbox.backgroundColor"
	local width	   = self:getWidth()
	local height   = self:getHeight()

	graphics.setColor( self:getScheme( property ) )
	graphics.rectangle( "fill", 0, 0, width, height )
end

function hudchattextbox:invalidateLayout()
	local parent = self:getParent()
	self:setWidth( parent:getWidth() - 2 * 36 )
	self:setHeight( parent:getHeight() - 46 - 9 - 2 * 36 )

	gui.panel.invalidateLayout( self )
end

gui.register( hudchattextbox, "hudchattextbox" )
