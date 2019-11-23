--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Frame Tab Panel class
--
--==========================================================================--

class "gui.frametabpanel" ( "gui.box" )

local frametabpanel = gui.frametabpanel

function frametabpanel:frametabpanel( parent, name )
	gui.box.box( self, parent, name )
	self:setDisplay( "block" )
	self:setPosition( "absolute" )
end

function frametabpanel:draw()
	gui.panel.drawBackground( self, self:getScheme( "frame.backgroundColor" ) )
	gui.box.draw( self )
end

function frametabpanel:invalidateLayout()
	self:setDimensions( self:getParent():getDimensions() )
	gui.panel.invalidateLayout( self )
end

local function getParentFrame( self )
	local panel = self
	while ( panel ~= nil ) do
		panel = panel:getParent()
		if ( typeof( panel, "frame" ) ) then
			return panel
		end
	end
end

function frametabpanel:keypressed( key, scancode, isrepeat )
	local parentFrame = getParentFrame( self )
	local parentFocus = parentFrame and parentFrame.focus
	if ( key == "tab" and ( self.focus or parentFocus ) ) then
		gui.frame.moveFocus( self )
	end

	return gui.panel.keypressed( self, key, scancode, isrepeat )
end
