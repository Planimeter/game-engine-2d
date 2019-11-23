--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Command Button class
--
--==========================================================================--

class "gui.commandbutton" ( "gui.button" )

local commandbutton = gui.commandbutton

function commandbutton:commandbutton( parent, name, text )
	gui.button.button( self, parent, name, text )
	self.width  = nil
	self.height = nil
	self:setDisplay( "inline-block" )
	self:setPosition( "static" )
	self:setPadding( 15, 18 )
	self:setBorderWidth( 0 )

	if ( text ) then
		parent:invalidateLayout()
	end
end

function commandbutton:drawBackground()
	local color = self:getScheme( "button.backgroundColor" )
	local width = self:getWidth()
	local height = self:getHeight()

	if ( self:isDisabled() ) then
		color = self:getScheme( "button.disabled.backgroundColor" )
		gui.panel.drawBackground( self, color )
		return
	else
		gui.panel.drawBackground( self, color )
	end

	local isFirstChild = self:isFirstChild()
	local x = isFirstChild and 1 or 0
	width = isFirstChild and width - 2 or width - 1
	height = height - 1

	local mouseover = ( self.mouseover or self:isChildMousedOver() )
	if ( self.mousedown and mouseover ) then
		color = self:getScheme( "button.mousedown.backgroundColor" )
		love.graphics.setColor( color )
		love.graphics.rectangle( "fill", x, 1, width, height )
	elseif ( self.mousedown or mouseover ) then
		color = self:getScheme( "button.mouseover.backgroundColor" )
		love.graphics.setColor( color )
		love.graphics.rectangle( "fill", x, 1, width, height )
	end
end

function commandbutton:drawBorder()
	if ( self:isLastChild() ) then
		return
	end

	local color = self:getScheme( "commandbutton.borderColor" )
	local width = self:getWidth()
	local height = self:getHeight()

	love.graphics.setColor( color )
	love.graphics.setLineStyle( "rough" )
	local lineWidth = 1
	love.graphics.setLineWidth( lineWidth )
	love.graphics.line(
		width - lineWidth / 2, 0,     -- Top-right
		width - lineWidth / 2, height -- Bottom-right
	)
end

function commandbutton:isFirstChild()
	local children = self:getParent():getChildren()
	return self == children[ 1 ]
end

function commandbutton:isLastChild()
	local children = self:getParent():getChildren()
	return self == children[ #children ]
end

function commandbutton:setParent( panel )
	gui.panel.setParent( self, panel )
	panel:invalidate()
end
