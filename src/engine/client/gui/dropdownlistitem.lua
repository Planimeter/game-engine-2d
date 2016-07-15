--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Drop-Down List Item class
--
--============================================================================--

class "dropdownlistitem" ( gui.radiobutton )

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
	local property = "dropdownlistitem.backgroundColor"
	local width    = self:getWidth()
	local height   = self:getHeight()

	if ( self:isSelected() ) then
		property = "dropdownlistitem.selected.backgroundColor"
	elseif ( self.mouseover ) then
		property = "dropdownlistitem.mouseover.backgroundColor"
	end

	graphics.setColor( self:getScheme( property ) )

	local selected = self.mouseover or self:isSelected()
	local offset   = selected and point( 1 ) or 0
	graphics.rectangle( "fill", offset, 0, width - 2 * offset, height )

	if ( selected ) then
		property = "dropdownlistitem.backgroundColor"
		self:drawBorders( property )
	end

	property = "dropdownlistitem.outlineColor"
	self:drawBorders( property )
end

function dropdownlistitem:drawBorders( property )
	local lineWidth = point( 1 )
	local width     = self:getWidth()
	local height    = self:getHeight()
	graphics.setColor( self:getScheme( property ) )
	graphics.setLineWidth( lineWidth )
	graphics.line(
		lineWidth / 2,      0,        -- Top-left
		lineWidth / 2,      height    -- Bottom-left
	)
	graphics.line(
		width - lineWidth / 2, 0,     -- Top-right
		width - lineWidth / 2, height -- Bottom-right
	)
end

function dropdownlistitem:drawText()
	local property = "button.textColor"

	if ( self:isDisabled() ) then
		property = "button.disabled.textColor"
	elseif ( self:isSelected() ) then
		property = "dropdownlistitem.selected.textColor"
	elseif ( self.mouseover ) then
		property = "dropdownlistitem.mouseover.textColor"
	end

	graphics.setColor( self:getScheme( property ) )

	local font = self:getScheme( "font" )
	graphics.setFont( font )
	local padding = point( 18 )
	local x = padding
	local y = self:getHeight() / 2 - font:getHeight() / 2 - point( 2 )
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

gui.register( dropdownlistitem, "dropdownlistitem" )
