--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Drop-Down List Item class
--
--============================================================================--

class "dropdownlistitem" ( gui.radiobutton )

function dropdownlistitem:dropdownlistitem( name, text )
	gui.radiobutton.radiobutton( self, nil, name, text )
	self.width  = 216
	self.height = 46
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
	local offset   = selected and 1 or 0
	graphics.rectangle( "fill", offset, 0, width - offset, height )

	width  = width  - 0.5
	height = height - 0.5
	if ( selected ) then
		property = "dropdownlistitem.backgroundColor"
		graphics.setColor( self:getScheme( property ) )
		graphics.line( 0,     -0.5, 0,     height )
		graphics.line( width, -0.5, width, height )
	end

	property = "dropdownlistitem.outlineColor"
	graphics.setColor( self:getScheme( property ) )
	graphics.line( 0,     -0.5, 0,     height )
	graphics.line( width, -0.5, width, height )
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
	local x = 18
	local y = self:getHeight() / 2 - font:getHeight() / 2 - 2
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
