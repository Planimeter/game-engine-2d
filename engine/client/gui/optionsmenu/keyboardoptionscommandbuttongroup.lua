--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Keyboard Options Command Button Group class
--
--============================================================================--

module( "gui.keyboardoptionscommandbuttongroup", package.class, package.inherit "gui.commandbuttongroup" )

function keyboardoptionscommandbuttongroup:keyboardoptionscommandbuttongroup( parent, name )
	gui.commandbuttongroup.commandbuttongroup( self, parent, name )
end

function keyboardoptionscommandbuttongroup:invalidateLayout()
	local children = self:getChildren()
	local width = 0
	if ( children ) then
		for i, commandbutton in ipairs( children ) do
			commandbutton:setX( width )
			width = width + commandbutton:getWidth()
		end
	end
	self:setWidth( width )

	local parent = self:getParent()
	local margin = point( 24 )
	self:setPos( margin, parent:getHeight() - self:getHeight() )
	gui.panel.invalidateLayout( self )
end


