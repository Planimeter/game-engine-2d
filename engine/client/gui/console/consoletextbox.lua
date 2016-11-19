--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Console Text Box class
--
--============================================================================--

module( "gui.console.textbox", package.class, package.inherit "gui.textbox" )

function _M:consoletextbox( parent, name )
	gui.textbox.textbox( self, parent, name, "" )

	self:setEditable( false )
	self:setMultiline( true )
	self:setScheme( "Console" )
end

function _M:draw()
	if ( self:getHeight() == point( 1 ) ) then
		return
	end

	self:drawBackground( "textbox.backgroundColor" )
	self:drawText()
	self:drawCursor()

	gui.panel.draw( self )

	self:drawForeground()
end

function _M:invalidateLayout()
	local parent         = self:getParent()
	local margin         = point( 36 )
	local titleBarHeight = point( 86 )
	local textboxHeight  = point( 46 )
	local marginBottom   = point( 9 )
	self:setWidth( parent:getWidth() - 2 * margin )
	self:setHeight(
		parent:getHeight() -
		titleBarHeight -
		textboxHeight -
		marginBottom -
		margin
	)

	gui.panel.invalidateLayout( self )
end
