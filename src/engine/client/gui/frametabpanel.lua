--========= Copyright © 2013-2014, Planimeter, All rights reserved. ==========--
--
-- Purpose: Frame Tab Panel class
--
--============================================================================--

class "frametabpanel" ( gui.panel )

function frametabpanel:frametabpanel( parent, name )
	gui.panel.panel( self, parent, name )
	self:setScheme( "Default" )
end

function frametabpanel:draw()
	if ( not self:isVisible() ) then
		return
	end

	gui.frame.drawBackground( self )

	gui.panel.draw( self )
end

function frametabpanel:invalidateLayout()
	self:setSize( self:getParent():getSize() )
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

function frametabpanel:keypressed( key, isrepeat )
	if ( not self:isVisible() ) then
		return
	end

	local parentFrame = getParentFrame( self )
	local parentFocus = parentFrame and parentFrame.focus
	if ( key == "tab" and ( self.focus or parentFocus ) ) then
		gui.frame.moveFocus( self )
	end

	gui.panel.keypressed( self, key, isrepeat )
end

gui.register( frametabpanel, "frametabpanel" )
