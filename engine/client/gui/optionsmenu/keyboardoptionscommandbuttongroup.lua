--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: Keyboard Options Command Button Group class
--
--==========================================================================--

class "gui.keyboardoptionscommandbuttongroup" ( "gui.commandbuttongroup" )

local keyboardoptionscommandbuttongroup = gui.keyboardoptionscommandbuttongroup

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
	local margin = 24
	self:setPos( margin, parent:getHeight() - self:getHeight() )
	gui.panel.invalidateLayout( self )
end
