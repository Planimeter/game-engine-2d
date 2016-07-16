--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Item Button class
--
--============================================================================--

class "itembutton" ( gui.button )

function itembutton:itembutton( parent, item )
	gui.button.button( self, parent )
	self.width  = point( 44 )
	self.height = point( 44 )

	self:setScheme( "Default" )
	self:setItem( item )
end

function itembutton:draw()
	self:drawIcon()
	self:drawCount()

	gui.panel.draw( self )
end

function itembutton:drawIcon()
	local item = self:getItemClass()
	if ( not item ) then
		return
	end

	graphics.setColor( color.white )
	local icon = self:getIcon()
	graphics.push()
		local scale  = point( 2 )
		local width  = icon:getWidth()
		local height = icon:getHeight()
		graphics.translate(
			self:getWidth() / 2 - ( width  * scale ) / 2,
			self:getHeight()    - ( height * scale )
		)
		graphics.scale( scale )
		graphics.draw( icon:getDrawable() )
	graphics.pop()
end

function itembutton:drawCount()
	local item = self:getItemClass()
	if ( not item ) then
		return
	end

	local itemdata = item.data
	if ( not itemdata or not itemdata.stackable ) then
		return
	end

	local property = "button.textColor"

	if ( self:isDisabled() ) then
		property = "button.disabled.textColor"
	end

	graphics.setColor( self:getScheme( property ) )

	local font = self:getScheme( "itemCountFont" )
	graphics.setFont( font )
	local x = self:getWidth() - font:getWidth( self:getCount() ) - point( 4 )
	graphics.print( self:getCount(), x, 0 )
end

function itembutton:getCount()
	local inventory = localplayer:getInventory()
	local item      = self:getItem()
	return inventory[ item ] or 0
end

accessor( itembutton, "icon" )
mutator( itembutton, "item" )

function itembutton:getItemClass()
	local classmap = _G.entities.getClassMap()
	local class    = self:getItem()
	return classmap[ class ]
end

mutator( itembutton, "source" )

function itembutton:setItem( item )
	self.item = item

	local item = self:getItemClass()
	if ( item ) then
		local name = item.data.name
		self.name  = name
		self.text  = name
		self.icon  = graphics.newImage( item.data.image )
	end
end

gui.register( itembutton, "itembutton" )
