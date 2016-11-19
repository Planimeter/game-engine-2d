--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Close Button class
--
--============================================================================--

module( "gui.closebutton", package.class, package.inherit "gui.button" )

closebutton.canFocus = false

function closebutton:closebutton( parent, name )
	gui.button.button( self, parent, name )
	local margin = point( 36 )
	self.width  = 2 * margin + point( 8 )  - point( 1 )
	self.height = 2 * margin + point( 16 ) - point( 2 )
	self.icon   = self:getScheme( "closebutton.icon" )
end

function closebutton:draw()
	local color = "closebutton.iconColor"

	if ( self.mousedown and self.mouseover ) then
		color = "closebutton.mousedown.iconColor"
	elseif ( self.mousedown or self.mouseover or self.focus ) then
		color = "closebutton.mouseover.iconColor"
	end

	graphics.setColor( self:getScheme( color ) )

	local width  = self:getWidth()
	local height = self:getHeight()
	local x = math.round( width  / 2 - self.icon:getWidth()  / 2 + point( 4 ) )
	local y = math.round( height / 2 - self.icon:getHeight() / 2 )
	love.graphics.draw( self.icon, x, y )

	gui.panel.draw( self )
end

function closebutton:onClick()
	local parent = self:getParent()
	parent:close()
end


