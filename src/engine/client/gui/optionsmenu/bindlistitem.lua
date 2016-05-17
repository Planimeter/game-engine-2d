--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Bind List Item class
--
--============================================================================--

-- These values are preserved during real-time scripting.
local trappedItem = gui.bindlistitem and gui.bindlistitem.trappedItem or nil

class "bindlistitem" ( gui.button )

bindlistitem.trappedItem = trappedItem

function bindlistitem:bindlistitem( parent, name, text, key, concommand )
	gui.button.button( self, parent, name, text )
	self.width      = parent:getWidth()
	self.height     = 30
	self.key        = key
	self.concommand = concommand
end

function bindlistitem:drawBackground()
	local property = "button.backgroundColor"
	local width    = self:getWidth()
	local height   = self:getHeight()

	if ( self:isDisabled() ) then
		property = "button.disabled.backgroundColor"
		graphics.setColor( self:getScheme( property ) )
		graphics.rectangle( "fill", 1, 0, width - 2, height )
		return
	end

	if ( self.mousedown and self.mouseover ) then
		property = "button.mousedown.backgroundColor"
		graphics.setColor( self:getScheme( property ) )
		graphics.rectangle( "fill", 1, 0, width - 2, height )
	elseif ( self.mousedown or self.mouseover ) then
		property = "button.mouseover.backgroundColor"
		graphics.setColor( self:getScheme( property ) )
		graphics.rectangle( "fill", 1, 0, width - 2, height )
	end
end

function bindlistitem:drawForeground()
end

function bindlistitem:drawText()
	local property = "button.textColor"

	if ( self:isDisabled() ) then
		property = "button.disabled.textColor"
	end

	graphics.setColor( self:getScheme( property ) )

	local font = self:getScheme( "font" )
	graphics.setFont( font )
	local margin = 18
	local x = margin
	local y = self:getHeight() / 2 - font:getHeight() / 2 - 2
	graphics.print( self:getText(), x, y )

	local label = "Key or Button"
	local key   = self:getKey()
	x = self:getWidth() - margin - font:getWidth( label ) / 2 - font:getWidth( key ) / 2
	graphics.print( key, x, y )
end

function bindlistitem:getConcommand()
	return self.concommand
end

function bindlistitem:getKey()
	return self.key
end

function bindlistitem.keyTrap( key )
	local self = gui.bindlistitem.trappedItem
	gui.bindlistitem.trappedItem = nil
	self:setKey( key )
	os.setCursorVisible( true )
	return true
end

function bindlistitem:onClick()
	gui.bindlistitem.trappedItem = self
	os.setCursorVisible( false )
	input.setKeyTrap( self.keyTrap )
end

function bindlistitem:setConcommand( concommand )
	self.concommand = concommand
end

function bindlistitem:setKey( key )
	local oldKey = self.key
	self.key     = key

	local panel = self:getParent()
	panel:getParent():onBindChange( item, key, oldKey, self:getConcommand() )
	self:invalidate()
end

gui.register( bindlistitem, "bindlistitem" )
