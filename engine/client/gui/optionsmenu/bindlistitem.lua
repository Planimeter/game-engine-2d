--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: Bind List Item class
--
--==========================================================================--

class "gui.bindlistitem" ( "gui.button" )

local bindlistitem = gui.bindlistitem

function bindlistitem:bindlistitem( parent, name, text, key, concommand )
	gui.button.button( self, parent, name, text )
	self.width      = parent:getWidth()
	self.height     = 30
	self.key        = key
	self.concommand = concommand
end

function bindlistitem:drawBackground()
	local color    = self:getScheme( "button.backgroundColor" )
	local width    = self:getWidth()
	local height   = self:getHeight()

	if ( self:isDisabled() ) then
		color = self:getScheme( "button.disabled.backgroundColor" )
		love.graphics.setColor( color )
		love.graphics.rectangle(
			"fill",
			1,
			0,
			width - 2,
			height
		)
		return
	end

	if ( self.mousedown and self.mouseover ) then
		color = self:getScheme( "button.mousedown.backgroundColor" )
		love.graphics.setColor( color )
		love.graphics.rectangle(
			"fill",
			1,
			0,
			width - 2,
			height
		)
	elseif ( self.mousedown or self.mouseover ) then
		color = self:getScheme( "button.mouseover.backgroundColor" )
		love.graphics.setColor( color )
		love.graphics.rectangle(
			"fill",
			1,
			0,
			width - 2,
			height
		)
	end
end

function bindlistitem:drawBorder()
end

function bindlistitem:drawText()
	local color = self:getScheme( "button.textColor" )

	if ( self:isDisabled() ) then
		color = self:getScheme( "button.disabled.textColor" )
	end

	love.graphics.setColor( color )

	local font = self:getScheme( "font" )
	love.graphics.setFont( font )
	local margin = 18
	local x = math.round( margin )
	local y = math.round( self:getHeight() / 2 - font:getHeight() / 2 )
	love.graphics.print( self:getText(), x, y )

	local label = "Key or Button"
	local key = self:getKey()
	x = self:getWidth() - margin
	x = x - font:getWidth( label ) / 2
	x = x - font:getWidth( key ) / 2
	x = math.round( x )
	love.graphics.print( key, x, y )
end

accessor( bindlistitem, "concommand" )
accessor( bindlistitem, "key" )

function bindlistitem.keyTrap( key )
	local self = bindlistitem.trappedItem
	bindlistitem.trappedItem = nil
	self:setKey( key )
	love.mouse.setVisible( true )
	return true
end

function bindlistitem:onClick()
	bindlistitem.trappedItem = self
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
