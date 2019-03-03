--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: Drop-Down List Item class
--
--==========================================================================--

class "gui.dropdownlistitem" ( "gui.radiobutton" )

local dropdownlistitem = gui.dropdownlistitem

function dropdownlistitem:dropdownlistitem( name, text )
	gui.radiobutton.radiobutton( self, nil, name, text )
	self:setPadding( 15, 18, 14 )
	self:setDisplay( "block" )
	self:setPosition( "static" )
	self.width  = 214
	self.height = nil
	self.text   = gui.text( self, name .. " Text Node", text or "Drop-Down List Item" )
end

function dropdownlistitem:draw()
	self:drawBackground()
	self:drawText()

	gui.box.draw( self )
end

function dropdownlistitem:drawBackground()
	local color  = self:getScheme( "dropdownlistitem.backgroundColor" )
	local width  = self:getWidth()
	local height = self:getHeight()

	if ( self:isSelected() ) then
		color = self:getScheme( "dropdownlistitem.selected.backgroundColor" )
	elseif ( ( self.mouseover or self:isChildMousedOver() ) ) then
		color = self:getScheme( "dropdownlistitem.mouseover.backgroundColor" )
	end

	love.graphics.setColor( color )
	love.graphics.rectangle( "fill", 0, 0, width, height )
end

function dropdownlistitem:drawText()
	local color = self:getScheme( "button.textColor" )

	if ( self:isDisabled() ) then
		color = self:getScheme( "button.disabled.textColor" )
	elseif ( self:isSelected() ) then
		color = self:getScheme( "dropdownlistitem.selected.textColor" )
	elseif ( ( self.mouseover or self:isChildMousedOver() ) ) then
		color = self:getScheme( "dropdownlistitem.mouseover.textColor" )
	end

	self.text:setColor( color )
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
	if ( ( self.mouseover or self:isChildMousedOver() ) and button == 1 ) then
		self.mousedown = true
	end

	local parentFrame = getParentFrame( self )
	if ( parentFrame ) then
		parentFrame:setFocusedFrame( true )
	end
end
