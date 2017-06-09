--=========== Copyright © 2017, Planimeter, All rights reserved. ===========--
--
-- Purpose: Drop-Down List Item Group class
--
--==========================================================================--

class "gui.dropdownlistitemgroup" ( "gui.radiobuttongroup" )

local dropdownlistitemgroup = gui.dropdownlistitemgroup

function dropdownlistitemgroup:dropdownlistitemgroup( parent, name )
	gui.radiobuttongroup.radiobuttongroup( self, nil, name )
	self.width = parent:getWidth()
	self.dropDownList = parent
	self:setScheme( "Default" )
end

function dropdownlistitemgroup:addItem( item, default )
	item:setParent( self )
	gui.radiobuttongroup.addItem( self, item )

	if ( default or #self:getItems() == 1 ) then
		item:setDefault( true )
	end

	self:invalidateLayout()
end

function dropdownlistitemgroup:draw()
	gui.panel.draw( self )

	local property = "dropdownlistitem.backgroundColor"
	self:drawBorders( property )
	property = "dropdownlistitem.outlineColor"
	self:drawBorders( property )
end

function dropdownlistitemgroup:drawBorders( property )
	local lineWidth = love.window.toPixels( 1 )
	local height    = self:getHeight()
	local width     = self:getWidth()
	love.graphics.setColor( self:getScheme( property ) )
	love.graphics.setLineWidth( lineWidth )
	love.graphics.line(
		0,     lineWidth / 2,          -- Top-left
		width, lineWidth / 2           -- Top-right
	)
	love.graphics.line(
		0,     height - lineWidth / 2, -- Bottom-left
		width, height - lineWidth / 2  -- Bottom-right
	)
end

function dropdownlistitemgroup:getDropDownList()
	return self.dropDownList
end

function dropdownlistitemgroup:invalidateLayout()
	self:updatePos()
	self:setWidth( self:getDropDownList():getWidth() )

	local listItems = self:getItems()
	if ( listItems ) then
		local y = 0
		for _, listItem in ipairs( listItems ) do
			listItem:setY( y )
			listItem:setWidth( self:getWidth() )
			y = y + listItem:getHeight()
		end
		self:setHeight( y )
	end
end

function dropdownlistitemgroup:isVisible()
	local dropDownList = self:getDropDownList()
	return dropDownList:isVisible() and dropDownList:isActive()
end

function dropdownlistitemgroup:mousepressed( x, y, button, istouch )
	if ( button == 1 ) then
		local dropDownList = self:getDropDownList()
		if ( dropDownList ~= gui._topPanel and
		   ( not ( self.mouseover or self:isChildMousedOver() ) ) ) then
			dropDownList:setActive( false )
		end
	end

	return gui.panel.mousepressed( self, x, y, button, istouch )
end

function dropdownlistitemgroup:onValueChanged( oldValue, newValue )
	local dropDownList = self:getDropDownList()
	dropDownList:setActive( false )
	dropDownList:onValueChanged( oldValue, newValue )
end

local x, y = 0, 0

function dropdownlistitemgroup:updatePos()
	local dropDownList = self:getDropDownList()
	if ( dropDownList ) then
		x, y = dropDownList:localToScreen()
		self:setPos( x, y + dropDownList:getHeight() )
	end
end
