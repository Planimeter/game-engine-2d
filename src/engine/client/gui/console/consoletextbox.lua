--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Console Text Box class
--
--============================================================================--

class "consoletextbox" ( gui.textbox )

function consoletextbox:consoletextbox( parent, name )
	gui.textbox.textbox( self, parent, name, "" )

	self:setEditable( false )
	self:setMultiline( true )
	self:setScheme( "Console" )
end

function consoletextbox:draw()
	if ( not self:isVisible() or self:getHeight() == 1 ) then
		return
	end

	self:drawBackground()
	-- TODO: Implement terminal string styling.
	self:drawText()
	self:drawCursor()

	gui.panel.draw( self )

	self:drawForeground()
end

function consoletextbox:drawBackground()
	if ( _INTERACTIVE ) then
		return
	end

	local property = "textbox.backgroundColor"
	local width	   = self:getWidth()
	local height   = self:getHeight()

	graphics.setColor( self:getScheme( property ) )
	graphics.rectangle( "fill", 0, 0, width, height )
end

function consoletextbox:invalidateLayout()
	local parent = self:getParent()
	self:setWidth( parent:getWidth() - 2 * 36 )
	self:setHeight( parent:getHeight() - 86 - 46 - 9 - 36 )

	gui.panel.invalidateLayout( self )
end

gui.register( consoletextbox, "consoletextbox" )
