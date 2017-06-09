--=========== Copyright © 2017, Planimeter, All rights reserved. ===========--
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
	if ( self:getHeight() == love.window.toPixels( 1 ) ) then
		return
	end

	self:drawBackground( "textbox.backgroundColor" )
	self:drawText()
	self:drawCursor()

	gui.panel.draw( self )

	self:drawForeground()
end

function textbox:invalidateLayout()
	local parent         = self:getParent()
	local margin         = love.window.toPixels( 36 )
	local titleBarHeight = love.window.toPixels( 86 )
	local textboxHeight  = love.window.toPixels( 46 )
	local marginBottom   = love.window.toPixels( 9 )
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
