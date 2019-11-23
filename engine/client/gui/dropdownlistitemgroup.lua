--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Drop-Down List Item Group class
--
--==========================================================================--

class "gui.dropdownlistitemgroup" ( "gui.radiobuttongroup" )

local dropdownlistitemgroup = gui.dropdownlistitemgroup

function dropdownlistitemgroup:dropdownlistitemgroup( parent, name )
	gui.radiobuttongroup.radiobuttongroup( self, nil, name )
	self:setParent( parent:getRootPanel() )
	self.height = nil
	self:setBorderWidth( 1 )
	self:setBorderColor( self:getScheme( "dropdownlistitem.borderColor" ) )
	self:setDisplay( "block" )
	self:setPosition( "absolute" )
	self.width = parent:getWidth()
	self:setUseFullscreenCanvas( true )
	self.dropDownList = parent
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
	if ( self:getItems() == nil ) then
		return
	end

	gui.box.draw( self )
end

accessor( dropdownlistitemgroup, "dropDownList" )

function dropdownlistitemgroup:invalidateLayout()
	self:updatePos()
	self:setWidth( self:getDropDownList():getWidth() )
	gui.panel.invalidateLayout( self )
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

function dropdownlistitemgroup:updatePos()
	local dropDownList = self:getDropDownList()
	if ( dropDownList == nil ) then
		return
	end

	local x, y = dropDownList:localToScreen()
	y = y + dropDownList:getHeight()

	local windowPadding = 4
	local overflow = y + self:getHeight() + windowPadding
	if ( overflow > love.graphics.getHeight() ) then
		overflow = overflow - love.graphics.getHeight()
		y = y - overflow
	end

	if ( y < windowPadding ) then
		y = windowPadding
	end

	self:setPos( x, y )
end
