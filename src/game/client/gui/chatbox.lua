--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Chat Text Box class
--
--============================================================================--

class "chatbox" ( gui.textbox )

function chatbox:chatbox( parent, name )
	gui.textbox.textbox( self, parent, name, "" )

	self:setEditable( false )
	self:setMultiline( true )
	self:setScheme( "Chat" )
end

function chatbox:draw()
	if ( not self:isVisible() or self:getHeight() == 1 ) then
		return
	end

	--self:drawBackground()
	self:drawForeground()
	self:drawText()
	self:drawCursor()

	gui.panel.draw( self )

end

function chatbox:drawBackground()
	local property = "textbox.backgroundColor"
	local width	   = self:getWidth()
	local height   = self:getHeight()

	graphics.setColor( color(  15,  10,	 10, 10 ) )
	graphics.rectangle( "fill", 0, 0, width, height )
end

function chatbox:invalidateLayout()
	local parent = self:getParent()
	self:setWidth( parent:getWidth() - 2 * 16 )
	self:setHeight( parent:getHeight() - 65)

	gui.panel.invalidateLayout( self )
end

gui.register( chatbox, "chatbox" )
