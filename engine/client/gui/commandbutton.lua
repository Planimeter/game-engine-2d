--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Command Button class
--
--============================================================================--

module( "gui.commandbutton", package.class, package.inherit "gui.button" )

function commandbutton:commandbutton( parent, name, text )
	gui.button.button( self, parent, name, text )

	if ( text ) then
		local font    = self:getScheme( "font" )
		local padding = point( 18 )
		self:setWidth( font:getWidth( text ) + 2 * padding )
		parent:invalidateLayout()
	end
end

function commandbutton:drawBackground()
	local color  = "button.backgroundColor"
	local width  = self:getWidth()
	local height = self:getHeight()

	if ( self:isDisabled() ) then
		color = "button.disabled.backgroundColor"
		gui.panel.drawBackground( self, color )
		return
	else
		gui.panel.drawBackground( self, color )
	end

	local x = self:isFirstChild() and point( 1 ) or 0
	width   = self:isFirstChild() and width - point( 2 ) or width - point( 1 )
	height  = height - point( 1 )

	if ( self.mousedown and self.mouseover ) then
		color = "button.mousedown.backgroundColor"
		graphics.setColor( self:getScheme( color ) )
		graphics.rectangle( "fill", x, point( 1 ), width, height )
	elseif ( self.mousedown or self.mouseover ) then
		color = "button.mouseover.backgroundColor"
		graphics.setColor( self:getScheme( color ) )
		graphics.rectangle( "fill", x, point( 1 ), width, height )
	end
end

function commandbutton:drawForeground()
	if ( self:isLastChild() ) then
		return
	end

	local color  = "commandbutton.outlineColor"
	local width  = self:getWidth()
	local height = self:getHeight()

	graphics.setColor( self:getScheme( color ) )
	local lineWidth = point( 1 )
	graphics.setLineWidth( lineWidth )
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


