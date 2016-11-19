--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Frame Tab Group class
--
--============================================================================--

module( "gui.frametabgroup", package.class, package.inherit "gui.radiobuttongroup" )

function frametabgroup:frametabgroup( parent, name )
	gui.radiobuttongroup.radiobuttongroup( self, parent, name )
	self.height = point( 61 )
	self:setScheme( "Default" )
end

function frametabgroup:addTab( tabName, default )
	local frametab = gui.frametab( self, tabName .. " Frame Tab", tabName )
	self:addItem( frametab )
	local numItems = #self:getItems()
	frametab:setValue( numItems )

	if ( default or numItems == 1 ) then
		frametab:setDefault( true )
	end
end

function frametabgroup:addItem( tab )
	gui.radiobuttongroup.addItem( self, tab )
	self:invalidateLayout()
end

function frametabgroup:draw()
	graphics.setColor( self:getScheme( "frametab.outlineColor" ) )
	local lineWidth = point( 1 )
	graphics.setLineWidth( lineWidth )
	love.graphics.line(
		lineWidth / 2, 0,               -- Top-left
		lineWidth / 2, self:getHeight() -- Bottom-left
	)

	gui.panel.draw( self )
end

function frametabgroup:invalidateLayout()
	local tabs = self:getItems()
	if ( tabs ) then
		local x = point( 1 )
		for _, tab in ipairs( tabs ) do
			tab:setX( x )
			x = x + tab:getWidth()
		end
		self:setWidth( x )
	end

	gui.panel.invalidateLayout( self )
end

function frametabgroup:onValueChanged( oldValue, newValue )
	local tabPanels = self:getParent():getTabPanels()
	tabPanels:setSelectedChild( newValue )
end


