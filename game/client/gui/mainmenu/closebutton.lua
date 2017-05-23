--=========== Copyright © 2017, Planimeter, All rights reserved. ===========--
--
-- Purpose: Main Menu Close Button class
--
--==========================================================================--

local gui    = gui
local love   = love
local point  = point
local unpack = unpack

class "gui.mainmenu.closebutton" ( "gui.closebutton" )

local closebutton = gui.mainmenu.closebutton

function closebutton:closebutton( parent )
	gui.closebutton.closebutton( self, parent, "Main Menu Close Button" )
	self.width  = point( 32 )
	self.height = self.width + point( 1 )
	self.icon   = self:getScheme( "mainmenuclosebutton.icon" )
end

function closebutton:draw()
	local iconColor = "mainmenuclosebutton.dark.iconColor"
	if ( self.mousedown and self.mouseover ) then
		iconColor = "mainmenuclosebutton.dark.mousedown.iconColor"
	elseif ( self.mousedown or self.mouseover ) then
		iconColor = "mainmenuclosebutton.dark.mouseover.iconColor"
	end

	local x =   self:getWidth()                 / 2 - self.icon:getWidth()  / 2
	local y = ( self:getHeight() - point( 1 ) ) / 2 - self.icon:getHeight() / 2
	love.graphics.setColor( unpack( self:getScheme( iconColor ) ) )
	love.graphics.draw( self.icon, x, y )

	gui.panel.draw( self )
end
