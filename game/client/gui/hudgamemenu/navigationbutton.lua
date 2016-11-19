--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Game Menu Navigation Button class
--
--============================================================================--

module( "gui.hudgamemenunavigationbutton", package.class, package.inherit "gui.radiobutton" )

function hudgamemenunavigationbutton:hudgamemenunavigationbutton( parent, name )
	gui.radiobutton.radiobutton( self, parent, name, name )

	local font = self:getScheme( "font" )
	self:setWidth( font:getWidth( self:getText() ) )
	self:setHeight( point( 45 ) )
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

	local property  = "hudgamemenunavigationbutton.borderColor"
	local lineWidth = point( 1 )
	local width     = self:getWidth()
	graphics.setColor( self:getScheme( property ) )
	graphics.setLineWidth( lineWidth )
	love.graphics.line(
		0,     lineWidth / 2, -- Top-left
		width, lineWidth / 2  -- Top-right
	)
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
	love.graphics.setFont( font )
	local x = 0
	local y = self:getHeight() / 2 - font:getHeight() / 2 - point( 1 )
	graphics.print( self.text, x, y )
end


