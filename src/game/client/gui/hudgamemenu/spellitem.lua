--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Spell Item class
--
--============================================================================--

class "spellitem" ( gui.button )

spellitem.trappedItem = trappedItem

function spellitem:spellitem( parent, name, spellName )
	require( "game.shared.spells." .. spellName )

	local spell = spell.getSpell( spellName )
	local text  = spell.name
	gui.button.button( self, parent, name, text )
	self.width  = parent:getWidth()
	self.height = 30
	self.spell  = spell
end

function spellitem:drawBackground()
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

function spellitem:drawForeground()
end

function spellitem:drawText()
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
	local key = self:getKey()
	x = self:getWidth() - margin - font:getWidth( label ) / 2 - font:getWidth( key ) / 2
	graphics.print( key, x, y )
end

function spellitem:getSpell()
	return self.spell
end

function spellitem.keyTrap( key )
	local self = gui.spellitem.trappedItem
	gui.spellitem.trappedItem = nil
	self:setKey( key )
	os.setCursorVisible( true )
	return true
end

function spellitem:onClick()
	gui.spellitem.trappedItem = self
	os.setCursorVisible( false )
	input.setKeyTrap( self.keyTrap )
end

gui.register( spellitem, "spellitem" )
