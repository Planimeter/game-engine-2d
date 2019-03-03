--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Console Text Box class
--
--==========================================================================--

class "gui.console.textbox" ( "gui.textbox" )

local textbox = gui.console.textbox

function textbox:textbox( parent, name )
	gui.textbox.textbox( self, parent, name, "" )

	self:setEditable( false )
	self:setMultiline( true )
	self:setScheme( "Console" )
end

function textbox:draw()
	if ( self:getHeight() == 1 ) then
		return
	end

	gui.panel.drawBackground( self, self:getScheme( "textbox.backgroundColor" ) )
	self:drawText()
	self:drawCursor()

	gui.panel.draw( self )

	self:drawBorder()
end

function textbox:invalidateLayout()
	local parent         = self:getParent()
	local margin         = 36
	local titleBarHeight = 86
	local textboxHeight  = 46
	local marginBottom   = 9
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
