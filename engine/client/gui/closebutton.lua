--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: Close Button class
--
--==========================================================================--

class "gui.closebutton" ( "gui.button" )

local closebutton = gui.closebutton

closebutton.canFocus = false

function closebutton:closebutton( parent, name )
	gui.button.button( self, parent, name )
	local margin = 36
	self.width = 2 * margin + 8 - 1
	self.height = 2 * margin + 16 - 2
	self.icon = self:getScheme( "icon" )
end

function closebutton:draw()
	local color = self:getScheme( "closebutton.iconColor" )

	if ( self.mousedown and self.mouseover ) then
		color = self:getScheme( "closebutton.mousedown.iconColor" )
	elseif ( self.mousedown or self.mouseover or self.focus ) then
		color = self:getScheme( "closebutton.mouseover.iconColor" )
	end

	love.graphics.setColor( color )

	local width = self:getWidth()
	local height = self:getHeight()
	local x = math.round( width / 2 - self.icon:getWidth() / 2 + 4 )
	local y = math.round( height / 2 - self.icon:getHeight() / 2 )
	love.graphics.draw( self.icon, x, y )

	gui.panel.draw( self )
end

function closebutton:onClick()
	local parent = self:getParent()
	parent:close()
end
