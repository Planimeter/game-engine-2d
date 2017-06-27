--=========== Copyright © 2017, Planimeter, All rights reserved. ===========--
--
-- Purpose: Item Button class
--
--==========================================================================--

class "gui.itembutton" ( "gui.button" )

local itembutton = gui.itembutton

function itembutton:itembutton( parent, item )
	gui.button.button( self, parent )
	self.width  = love.window.toPixels( 44 )
	self.height = love.window.toPixels( 44 )

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

	love.graphics.setColor( color.white )
	local icon = self:getIcon()
	love.graphics.push()
		local scale  = 2 * love.window.getPixelScale()
		local width  = icon:getWidth()
		local height = icon:getHeight()
		love.graphics.translate(
			self:getWidth() / 2 - ( width  * scale ) / 2,
			self:getHeight()    - ( height * scale )
		)
		love.graphics.scale( scale )
		love.graphics.draw( icon )
	love.graphics.pop()
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

	love.graphics.setColor( self:getScheme( property ) )

	local font = self:getScheme( "itemCountFont" )
	love.graphics.setFont( font )
	local x = math.round( self:getWidth() - font:getWidth( self:getCount() ) - love.window.toPixels( 4 ) )
	love.graphics.print( self:getCount(), x, 0 )
end

function itembutton:getCount()
	local inventory = localplayer:getInventory()
	local item      = self:getItem()
	return inventory[ item ] or 0
end

accessor( itembutton, "icon" )
accessor( itembutton, "item" )

function itembutton:getItemClass()
	local classmap = _G.entities.getClassMap()
	local class    = self:getItem()
	return classmap[ class ]
end

accessor( itembutton, "source" )

function itembutton:setItem( item )
	self.item = item

	local item = self:getItemClass()
	if ( item ) then
		local name = item.data.name
		self.name  = name
		self.text  = name
		self.icon  = love.graphics.newImage( item.data.image )
	end
end
