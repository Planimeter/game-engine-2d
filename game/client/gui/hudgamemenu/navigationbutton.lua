--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Game Menu Navigation Button class
--
--==========================================================================--

class "gui.hudgamemenunavigationbutton" ( "gui.radiobutton" )

local hudgamemenunavigationbutton = gui.hudgamemenunavigationbutton

function hudgamemenunavigationbutton:hudgamemenunavigationbutton( parent, name )
	gui.radiobutton.radiobutton( self, parent, name, name )
	self:setDisplay( "inline" )
	self:setPosition( "static" )
	self:setMarginRight( 18 )

	local font = self:getScheme( "font" )
	self:setWidth( font:getWidth( self:getText() ) )
	self:setHeight( 45 )
	self:setValue( name )
end

function hudgamemenunavigationbutton:draw()
	self:drawBorder()
	self:drawLabel()
	gui.box.draw( self )
end

function hudgamemenunavigationbutton:drawBorder()
	if ( not self:isSelected() ) then
		return
	end

	local property  = "hudgamemenunavigationbutton.borderColor"
	local lineWidth = 1
	local width     = self:getWidth()
	love.graphics.setColor( self:getScheme( property ) )
	love.graphics.setLineStyle( "rough" )
	love.graphics.setLineWidth( lineWidth )
	love.graphics.line(
		0,     lineWidth / 2, -- Top-left
		width, lineWidth / 2  -- Top-right
	)
end

function hudgamemenunavigationbutton:drawLabel()
	if ( self:isDisabled() ) then
		love.graphics.setColor( self:getScheme( "radiobutton.disabled.textColor" ) )
	elseif ( self:isSelected() ) then
		love.graphics.setColor( self:getScheme( "hudgamemenunavigationbutton.borderColor" ) )
	elseif ( self.mouseover ) then
		love.graphics.setColor( self:getScheme( "hudgamemenunavigationbutton.mouseover.textColor" ) )
	else
		love.graphics.setColor( self:getScheme( "hudgamemenunavigationbutton.textColor" ) )
	end

	local font = self:getScheme( "font" )
	love.graphics.setFont( font )
	local x = 0
	local y = math.round( self:getHeight() / 2 - font:getHeight() / 2 - 1 )
	love.graphics.print( self:getText(), x, y )
end
