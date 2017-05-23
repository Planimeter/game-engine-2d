--=========== Copyright © 2017, Planimeter, All rights reserved. ===========--
--
-- Purpose: Drop-Down List Item class
--
--==========================================================================--

class "gui.dropdownlistitem" ( "gui.radiobutton" )

local dropdownlistitem = gui.dropdownlistitem

function dropdownlistitem:dropdownlistitem( name, text )
	gui.radiobutton.radiobutton( self, nil, name, text )
	self.width  = point( 216 )
	self.height = point( 46 )
	self.text   = text or "Drop-Down List Item"
end

function dropdownlistitem:draw()
	self:drawBackground()
	self:drawText()

	gui.panel.draw( self )
end

function dropdownlistitem:drawBackground()
	local color  = "dropdownlistitem.backgroundColor"
	local width  = self:getWidth()
	local height = self:getHeight()

	if ( self:isSelected() ) then
		color = "dropdownlistitem.selected.backgroundColor"
	elseif ( self.mouseover ) then
		color = "dropdownlistitem.mouseover.backgroundColor"
	end

	love.graphics.setColor( self:getScheme( color ) )

	local selected = self.mouseover or self:isSelected()
	local offset   = selected and point( 1 ) or 0
	love.graphics.rectangle( "fill", offset, 0, width - 2 * offset, height )

	if ( selected ) then
		color = "dropdownlistitem.backgroundColor"
		self:drawBorders( color )
	end

	color = "dropdownlistitem.outlineColor"
	self:drawBorders( color )
end

function dropdownlistitem:drawBorders( color )
	local lineWidth = point( 1 )
	local width     = self:getWidth()
	local height    = self:getHeight()
	love.graphics.setColor( self:getScheme( color ) )
	love.graphics.setLineWidth( lineWidth )
	love.graphics.line(
		lineWidth / 2,      0,        -- Top-left
		lineWidth / 2,      height    -- Bottom-left
	)
	love.graphics.line(
		width - lineWidth / 2, 0,     -- Top-right
		width - lineWidth / 2, height -- Bottom-right
	)
end

function dropdownlistitem:drawText()
	local color = "button.textColor"

	if ( self:isDisabled() ) then
		color = "button.disabled.textColor"
	elseif ( self:isSelected() ) then
		color = "dropdownlistitem.selected.textColor"
	elseif ( self.mouseover ) then
		color = "dropdownlistitem.mouseover.textColor"
	end

	love.graphics.setColor( self:getScheme( color ) )

	local font = self:getScheme( "font" )
	love.graphics.setFont( font )
	local x = point( 18 )
	local y = self:getHeight() / 2 - font:getHeight() / 2
	graphics.print( self:getText(), x, y )
end

local function getParentFrame( self )
	local panel = self:getParent():getDropDownList()
	while ( panel ~= nil ) do
		panel = panel:getParent()
		if ( typeof( panel, "frame" ) ) then
			return panel
		end
	end
end

function dropdownlistitem:mousepressed( x, y, button, istouch )
	if ( self.mouseover and button == 1 ) then
		self.mousedown = true
	end

	local parentFrame = getParentFrame( self )
	if ( parentFrame ) then
		parentFrame:setFocusedFrame( true )
	end
end
