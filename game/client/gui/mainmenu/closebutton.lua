--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Main Menu Close Button class
--
--============================================================================--

class "mainmenuclosebutton" ( gui.closebutton )

function mainmenuclosebutton:mainmenuclosebutton( parent )
	gui.closebutton.closebutton( self, parent, "Main Menu Close Button" )
	self.width  = point( 32 )
	self.height = self.width + point( 1 )
	self.icon   = self:getScheme( "mainmenuclosebutton.icon" )
end

function mainmenuclosebutton:draw()
	local iconColor = "mainmenuclosebutton.dark.iconColor"
	if ( self.mousedown and self.mouseover ) then
		iconColor = "mainmenuclosebutton.dark.mousedown.iconColor"
	elseif ( self.mousedown or self.mouseover ) then
		iconColor = "mainmenuclosebutton.dark.mouseover.iconColor"
	end

	local x =   self:getWidth()                 / 2 - self.icon:getWidth()  / 2
	local y = ( self:getHeight() - point( 1 ) ) / 2 - self.icon:getHeight() / 2
	graphics.setColor( self:getScheme( iconColor ) )
	love.graphics.draw( self.icon, x, y )

	gui.panel.draw( self )
end

gui.register( mainmenuclosebutton, "mainmenuclosebutton" )
