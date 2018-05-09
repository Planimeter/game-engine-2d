--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: Command Button class
--
--==========================================================================--

class "gui.commandbutton" ( "gui.button" )

local commandbutton = gui.commandbutton

function commandbutton:commandbutton( parent, name, text )
	gui.button.button( self, parent, name, text )

	if ( text ) then
		local font = self:getScheme( "font" )
		local padding = love.window.toPixels( 18 )
		self:setWidth( font:getWidth( text ) + 2 * padding )
		parent:invalidateLayout()
	end
end

function commandbutton:drawBackground()
	local color = "button.backgroundColor"
	local width = self:getWidth()
	local height = self:getHeight()

	if ( self:isDisabled() ) then
		color = "button.disabled.backgroundColor"
		gui.panel.drawBackground( self, color )
		return
	else
		gui.panel.drawBackground( self, color )
	end

	local isFirstChild = self:isFirstChild()
	local toPixels = love.window.toPixels
	local x = isFirstChild and toPixels( 1 ) or 0
	width = isFirstChild and width - toPixels( 2 ) or width - toPixels( 1 )
	height = height - toPixels( 1 )

	if ( self.mousedown and self.mouseover ) then
		color = "button.mousedown.backgroundColor"
		love.graphics.setColor( self:getScheme( color ) )
		love.graphics.rectangle( "fill", x, toPixels( 1 ), width, height )
	elseif ( self.mousedown or self.mouseover ) then
		color = "button.mouseover.backgroundColor"
		love.graphics.setColor( self:getScheme( color ) )
		love.graphics.rectangle( "fill", x, toPixels( 1 ), width, height )
	end
end

function commandbutton:drawForeground()
	if ( self:isLastChild() ) then
		return
	end

	local color = "commandbutton.outlineColor"
	local width = self:getWidth()
	local height = self:getHeight()

	love.graphics.setColor( self:getScheme( color ) )
	love.graphics.setLineStyle( "rough" )
	local lineWidth = love.window.toPixels( 1 )
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
