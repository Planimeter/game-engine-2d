--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Item Button class
--
--============================================================================--

class "itembutton" ( gui.button )

function itembutton:itembutton( parent, item )
	gui.button.button( self, parent )
	self.width  = 44
	self.height = 44

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
		graphics.translate( 6, -6 )
		local scale  = 2
		local width  = icon:getWidth()
		local height = icon:getHeight()
		graphics.scale( scale )
		graphics.translate(
			( width  / scale ) / 2 - width  / 2,
			( height / scale ) / 2 - height / 2
		)
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
	local x = self:getWidth() - font:getWidth( self:getCount() ) - 4
	graphics.print( self:getCount(), x, 0 )
end

function itembutton:getCount()
	local inventory = localplayer:getInventory()
	local item      = self:getItem()
	return inventory[ item ] or 0
end

function itembutton:getIcon()
	return self.icon
end

function itembutton:getItem()
	return self.item
end

function itembutton:getItemClass()
	local classmap = _G.entities.getClassMap()
	local class    = self:getItem()
	return classmap[ class ]
end

function itembutton:getSource()
	return self.source
end

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

function itembutton:setSource( source )
	self.source = source
end

gui.register( itembutton, "itembutton" )
