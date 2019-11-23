--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Item Button class
--
--==========================================================================--

require( "engine.client.gui.dropdownlist" )

class "gui.itembutton" ( "gui.dropdownlist" )

local itembutton = gui.itembutton

function itembutton:itembutton( parent, item )
	gui.button.button( self, parent, name )
	self.listItemGroup = gui.optionsitemgroup(
		self, item .. " Options Item Group"
	)
	self.listItemGroup:setParent( _G.g_Viewport )
	self.active = false
	self.width  = 44
	self.height = 44

	self:setItem( item )
end

function itembutton:draw()
	self:drawIcon()
	self:drawCount()

	gui.panel.draw( self )
end

function itembutton:drawIcon()
	local item = self:getItemClass()
	if ( item == nil ) then
		return
	end

	love.graphics.setColor( color.white )

	local selected = self:isSelected()
	if ( selected ) then
		love.graphics.setColor( color.red )
	end

	local icon = self:getIcon()
	love.graphics.push()
		local scale  = 2
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
	if ( item == nil ) then
		return
	end

	local itemdata = item.data
	if ( itemdata == nil or not itemdata.stackable ) then
		return
	end

	local property = "itembutton.textColor"

	if ( self:isDisabled() ) then
		property = "button.disabled.textColor"
	end

	love.graphics.setColor( self:getScheme( property ) )

	local font = self:getScheme( "itemCountFont" )
	love.graphics.setFont( font )
	love.graphics.print( self:getCount() )
end

function itembutton:mousepressed( x, y, button, istouch )
	if ( button == 1 ) then
	end

	if ( button == 2 ) then
		if ( self.mouseover ) then
			self.mousedown = true
			self:invalidate()

			if ( not self:isDisabled() ) then
				self:setActive( not self:isActive(), x, y )
				self:onClick()

				-- Prevent g_GameMenu from stealing focus
				return true
			end
		else
			if ( self:isActive() and not self:isChildMousedOver() ) then
				self:setActive( false )
			end
		end
	end
end

local function addOptions( itembutton, classname )
	-- item:getInventoryOptions()
	local optionsitem  = nil
	local name         = "Option Item"
	local n            = 1
	local item         = item.getClass( classname )
	local self         = item
	local options      = item.__index( self, "getInventoryOptions" )( self )

	-- Inventory options
	local n = 0
	for k, option in pairs( options ) do
		local panelName = name .. " " .. n
		optionsitem = gui.optionsitem( itembutton, panelName, option.name )
		optionsitem:setEntity( item.data.name )
		optionsitem:setValue( option.value )
		n = n + 1
	end
	return n
end

local function createDropdown( itembutton, classname )
	local optionsitem  = nil
	local name         = "Option Item"
	local n            = 1

	-- Is this item selected?
	local itemSelected = false
	local _itembutton  = g_Inventory:getSelectedItem()
	if (  _itembutton ) then
		local item = _itembutton:getItemClass()
		if ( item ) then
			if ( classname == item.__type ) then
				itemSelected = true
			end
		end
	end

	if ( not itemSelected ) then
		n = n + addOptions( itembutton, classname )
	end

	-- Cancel inventory selection
	local panelName = name .. " " .. n
	optionsitem = gui.optionsitem( panelName, "Cancel" )
	optionsitem:setValue( function()
		g_Inventory:select( nil )
	end )
	itembutton:addItem( optionsitem )
	n = n + 1
end

function itembutton:onClick()
	local listItemGroup = self:getListItemGroup()
	if ( listItemGroup ) then
		listItemGroup:removeChildren()
	end

	createDropdown( self, self:getItem() )
end

function itembutton:getCount()
	local inventory = localplayer:getInventory()
	local item      = self:getItem()
	return inventory[ item ] or 0
end

accessor( itembutton, "icon" )
accessor( itembutton, "item" )

function itembutton:getItemClass()
	local item = self:getItem()
	return _G.item.getClass( item )
end

gui.accessor( itembutton, "selected", "is" )

function itembutton:setActive( active, x, y )
	x = x or 0
	y = y or 0
	local listItemGroup = self:getListItemGroup()
	if ( listItemGroup ) then
		listItemGroup:setPos( x, y )
		listItemGroup:moveToFront()
	end
	self.active = active
	gui.setFocusedPanel( self, active )
end

function itembutton:setItem( item )
	self.item = item

	local item = self:getItemClass()
	if ( item ) then
		local name = item.data.name
		self.name  = name
		self.text  = name
		self.icon  = love.graphics.newImage( item.data.image )
		self.icon:setFilter( "nearest", "nearest" )
	end
end

function itembutton:onRemove()
	self.listItemGroup = nil
	gui.panel.onRemove( self )
end
