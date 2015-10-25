--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Game Menu Navigation Button class
--
--============================================================================--

class "hudgamemenunavigationbutton" ( gui.radiobutton )

function hudgamemenunavigationbutton:hudgamemenunavigationbutton( parent, name )
	gui.radiobutton.radiobutton( self, parent, name, name )

	local font = self:getScheme( "font" )
	self:setWidth( font:getWidth( self:getText() ) )
	self:setHeight( 45 )
	self:setValue( name )
end

function hudgamemenunavigationbutton:draw()
	self:drawBorder()
	self:drawLabel()
	gui.panel.draw( self )
end

function hudgamemenunavigationbutton:drawBorder()
	if ( not self:isSelected() ) then
		return
	end

	local property = "hudgamemenunavigationbutton.borderColor"
	local width    = self:getWidth()
	graphics.setColor( self:getScheme( property ) )
	graphics.line( 0, 0, width, 0 )
end

function hudgamemenunavigationbutton:drawLabel()
	if ( self:isDisabled() ) then
		graphics.setColor( self:getScheme( "radiobutton.disabled.textColor" ) )
	elseif ( self:isSelected() ) then
		graphics.setColor( self:getScheme( "hudgamemenunavigationbutton.borderColor" ) )
	elseif ( self.mouseover ) then
		graphics.setColor( self:getScheme( "hudgamemenunavigationbutton.mouseover.textColor" ) )
	else
		graphics.setColor( self:getScheme( "hudgamemenunavigationbutton.textColor" ) )
	end

	local font = self:getScheme( "font" )
	graphics.setFont( font )
	local x = 0
	local y = self:getHeight() / 2 - font:getHeight() / 2 - 1
	graphics.print( self.text, x, y )
end

gui.register( hudgamemenunavigationbutton, "hudgamemenunavigationbutton" )
