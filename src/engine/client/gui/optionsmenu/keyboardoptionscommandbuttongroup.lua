--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Keyboard Options Command Button Group class
--
--============================================================================--

class "keyboardoptionscommandbuttongroup" ( gui.commandbuttongroup )

function keyboardoptionscommandbuttongroup:keyboardoptionscommandbuttongroup( parent, name )
	gui.commandbuttongroup.commandbuttongroup( self, parent, name )
end

function keyboardoptionscommandbuttongroup:invalidateLayout()
	local width = 0
	if ( self:getChildren() ) then
		for i, commandbutton in ipairs( self:getChildren() ) do
			commandbutton:setX( width )
			width = width + commandbutton:getWidth()
		end
	end
	self:setWidth( width )

	local parent = self:getParent()
	local margin = 24
	self:setPos( margin, parent:getHeight() - self:getHeight() )
	gui.panel.invalidateLayout( self )
end

gui.register( keyboardoptionscommandbuttongroup, "keyboardoptionscommandbuttongroup" )
