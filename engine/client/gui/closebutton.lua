--=========== Copyright © 2017, Planimeter, All rights reserved. ===========--
--
-- Purpose: Close Button class
--
--==========================================================================--

class "gui.closebutton" ( "gui.button" )

local closebutton = gui.closebutton

closebutton.canFocus = false

function closebutton:closebutton( parent, name )
	gui.button.button( self, parent, name )
	local toPixels = love.window.toPixels
	local margin = toPixels( 36 )
	self.width = 2 * margin + toPixels( 8 )  - toPixels( 1 )
	self.height = 2 * margin + toPixels( 16 ) - toPixels( 2 )
	self.icon = self:getScheme( "closebutton.icon" )
end

function closebutton:draw()
	local color = "closebutton.iconColor"

	if ( self.mousedown and self.mouseover ) then
		color = "closebutton.mousedown.iconColor"
	elseif ( self.mousedown or self.mouseover or self.focus ) then
		color = "closebutton.mouseover.iconColor"
	end

	love.graphics.setColor( self:getScheme( color ) )

	local width = self:getWidth()
	local height = self:getHeight()
	local toPixels = love.window.toPixels
	local x = width / 2 - self.icon:getWidth() / 2 + toPixels( 4 )
	local y = height / 2 - self.icon:getHeight() / 2
	x = math.round( x )
	y = math.round( y )
	love.graphics.draw( self.icon, x, y )

	gui.panel.draw( self )
end

function closebutton:onClick()
	local parent = self:getParent()
	parent:close()
end
