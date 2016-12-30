--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Main Menu Button class
--
--============================================================================--

local gui  = gui
local love = love

class "gui.mainmenu.button" ( "gui.button" )

function _M:button( parent, text )
	gui.button.button( self, parent, text and text or "Blank" .. " Button",
	                   text or "" )
	local font  = self:getScheme( "mainmenuFont" )
	self.height = font:getHeight()
end

function _M:draw()
	local textColor = "mainmenubutton.dark.textColor"
	if ( self:isDisabled() ) then
		textColor = "mainmenubutton.dark.disabled.textColor"
	elseif ( self.mousedown and self.mouseover ) then
		textColor = "mainmenubutton.dark.mousedown.textColor"
	elseif ( self.mousedown or self.mouseover or self.focus ) then
		textColor = "mainmenubutton.dark.mouseover.textColor"
	end

	local font = self:getScheme( "mainmenuFont" )
	love.graphics.setFont( font )
	local x =   self:getWidth()        / 2 - font:getWidth( self.text ) / 2
	local y = ( self:getHeight() - 1 ) / 2 - font:getHeight()           / 2 - 1
	love.graphics.setColor( self:getScheme( textColor ) )
	love.graphics.print( ( self.text ), 0, y )

	gui.panel.draw( self )
end
