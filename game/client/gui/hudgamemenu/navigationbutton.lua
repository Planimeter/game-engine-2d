--=========== Copyright © 2017, Planimeter, All rights reserved. ===========--
--
-- Purpose: Game Menu Navigation Button class
--
--==========================================================================--

class "gui.hudgamemenunavigationbutton" ( "gui.radiobutton" )

local hudgamemenunavigationbutton = gui.hudgamemenunavigationbutton

function hudgamemenunavigationbutton:hudgamemenunavigationbutton( parent, name )
	gui.radiobutton.radiobutton( self, parent, name, name )

	local font = self:getScheme( "font" )
	self:setWidth( font:getWidth( self:getText() ) )
	self:setHeight( love.window.toPixels( 45 ) )
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
	local lineWidth = love.window.toPixels( 1 )
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
	local y = math.round( self:getHeight() / 2 - font:getHeight() / 2 - love.window.toPixels( 1 ) )
	love.graphics.print( self.text, x, y )
end
