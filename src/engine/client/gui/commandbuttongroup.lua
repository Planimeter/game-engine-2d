--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Command Button Group class
--
--============================================================================--

class "commandbuttongroup" ( gui.panel )

function commandbuttongroup:commandbuttongroup( parent, name )
	gui.panel.panel( self, parent, name )
	self.height = 46

	self:setScheme( "Default" )
	self:invalidateLayout()
end

function commandbuttongroup:draw()
	gui.panel.draw( self )

	local property = "commandbuttongroup.outlineColor"
	local width    = self:getWidth()
	local height   = self:getHeight()

	graphics.setColor( self:getScheme( property ) )
	graphics.line(
		0,               0 + height - 1,
		0,               0,
		0 + width - 0.5, 0,
		0 + width - 0.5, 0 + height - 1
	)
end

function commandbuttongroup:invalidateLayout()
	local width = 0
	if ( self:getChildren() ) then
		for i, commandbutton in ipairs( self:getChildren() ) do
			commandbutton:setX( width )
			width = width + commandbutton:getWidth()
		end
	end
	self:setWidth( width )

	local parent = self:getParent()
	local margin = typeof( parent, "tabbedframe" ) and 24 or 36
	self:setPos(
		parent:getWidth()  - self:getWidth() - margin,
		parent:getHeight() - self:getHeight()
	)
	gui.panel.invalidateLayout( self )
end

gui.register( commandbuttongroup, "commandbuttongroup" )
