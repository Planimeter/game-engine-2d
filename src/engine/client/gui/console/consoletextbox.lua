--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
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
	if ( self:getHeight() == point( 1 ) ) then
		return
	end

	self:drawBackground()
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
	local width    = self:getWidth()
	local height   = self:getHeight()

	graphics.setColor( self:getScheme( property ) )
	graphics.rectangle( "fill", 0, 0, width, height )
end

function consoletextbox:invalidateLayout()
	local parent = self:getParent()
	local margin = point( 36 )
	self:setWidth( parent:getWidth() - 2 * margin )

	local titleBarHeight = point( 86 )
	local textboxHeight  = point( 46 )
	local marginBottom   = point( 9 )
	self:setHeight(
		parent:getHeight() -
		titleBarHeight -
		textboxHeight -
		marginBottom -
		margin
	)

	gui.panel.invalidateLayout( self )
end

gui.register( consoletextbox, "consoletextbox" )
