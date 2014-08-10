--========= Copyright © 2013-2014, Planimeter, All rights reserved. ==========--
--
-- Purpose: Main Menu Button class
--
--============================================================================--

class "mainmenubutton" ( gui.button )

function mainmenubutton:mainmenubutton( parent, text )
	gui.button.button( self, parent, text and text or "Blank" .. " Button",
					   text or "" )
	local font  = self:getScheme( "mainmenuFont" )
	self.height = font:getHeight()
end

function mainmenubutton:draw()
	if ( not self:isVisible() ) then
		return
	end

	local textColor			  = "mainmenubutton.dark.textColor"
	local textDropShadowColor = "mainmenubutton.dark.textDropShadowColor"

	if ( self:isDisabled() ) then
		textColor = "mainmenubutton.dark.disabled.textColor"
	elseif ( self.mousedown and self.mouseover ) then
		textColor = "mainmenubutton.dark.mousedown.textColor"
	elseif ( self.mousedown or self.mouseover or self.focus ) then
		textColor = "mainmenubutton.dark.mouseover.textColor"
	end

	local font = self:getScheme( "mainmenuFont" )
	graphics.setFont( font )
	local x =   self:getWidth()		   / 2 - font:getWidth( self.text ) / 2
	local y = ( self:getHeight() - 1 ) / 2 - font:getHeight()			/ 2 - 1
	graphics.setColor( self:getScheme( textDropShadowColor ) )
	graphics.print( ( self.text ), 0, y + 1 )
	graphics.setColor( self:getScheme( textColor ) )
	graphics.print( ( self.text ), 0, y )

	gui.panel.draw( self )
end

gui.register( mainmenubutton, "mainmenubutton" )
