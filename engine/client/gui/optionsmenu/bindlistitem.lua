--=========== Copyright © 2017, Planimeter, All rights reserved. ===========--
--
-- Purpose: Bind List Item class
--
--==========================================================================--

-- These values are preserved during real-time scripting.
local trappedItem = gui.bindlistitem and gui.bindlistitem.trappedItem or nil

class "gui.bindlistitem" ( "gui.button" )

local bindlistitem = gui.bindlistitem

bindlistitem.trappedItem = trappedItem

function bindlistitem:bindlistitem( parent, name, text, key, concommand )
	gui.button.button( self, parent, name, text )
	self.width      = parent:getWidth()
	self.height     = point( 30 )
	self.key        = key
	self.concommand = concommand
end

function bindlistitem:drawBackground()
	local color  = "button.backgroundColor"
	local width  = self:getWidth()
	local height = self:getHeight()

	if ( self:isDisabled() ) then
		color = "button.disabled.backgroundColor"
		love.graphics.setColor( self:getScheme( color ) )
		love.graphics.rectangle( "fill", point( 1 ), 0, width - point( 2 ), height )
		return
	end

	if ( self.mousedown and self.mouseover ) then
		color = "button.mousedown.backgroundColor"
		love.graphics.setColor( self:getScheme( color ) )
		love.graphics.rectangle( "fill", point( 1 ), 0, width - point( 2 ), height )
	elseif ( self.mousedown or self.mouseover ) then
		color = "button.mouseover.backgroundColor"
		love.graphics.setColor( self:getScheme( color ) )
		love.graphics.rectangle( "fill", point( 1 ), 0, width - point( 2 ), height )
	end
end

function bindlistitem:drawForeground()
end

function bindlistitem:drawText()
	local color = "button.textColor"

	if ( self:isDisabled() ) then
		color = "button.disabled.textColor"
	end

	love.graphics.setColor( self:getScheme( color ) )

	local font = self:getScheme( "font" )
	love.graphics.setFont( font )
	local margin = point( 18 )
	local x = margin
	local y = self:getHeight() / 2 - font:getHeight() / 2
	graphics.print( self:getText(), x, y )

	local label = "Key or Button"
	local key = self:getKey()
	x = self:getWidth() - margin
	x = x - font:getWidth( label ) / 2
	x = x - font:getWidth( key ) / 2
	graphics.print( key, x, y )
end

accessor( bindlistitem, "concommand" )
accessor( bindlistitem, "key" )

function bindlistitem.keyTrap( key )
	local self = gui.bindlistitem.trappedItem
	gui.bindlistitem.trappedItem = nil
	self:setKey( key )
	love.mouse.setVisible( true )
	return true
end

function bindlistitem:onClick()
	gui.bindlistitem.trappedItem = self
	love.mouse.setVisible( false )
	input.setKeyTrap( self.keyTrap )
end

function bindlistitem:setKey( key )
	local oldKey = self.key
	self.key     = key

	local panel = self:getParent()
	panel:getParent():onBindChange( item, key, oldKey, self:getConcommand() )
	self:invalidate()
end
