--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: Scrollable Panel class
--
--==========================================================================--

class "gui.scrollablepanel" ( "gui.panel" )

local scrollablepanel = gui.scrollablepanel

function scrollablepanel:scrollablepanel( parent, name )
	gui.panel.panel( self, parent, name )
	self.panel     = gui.panel( self, self:getName() .. " Inner Panel" )
	self.scrollbar = gui.scrollbar( self, self:getName() .. " Scrollbar" )
	self.scrollbar.onValueChanged = function( _, oldValue, newValue )
		self.panel:setY( -newValue )
	end

	self:setScheme( "Default" )
end

accessor( scrollablepanel, "innerHeight" )
accessor( scrollablepanel, "innerPanel", "panel" )
accessor( scrollablepanel, "scrollbar" )

function scrollablepanel:invalidateLayout()
	self:setSize( self:getSize() )
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

function scrollablepanel:keypressed( key, scancode, isrepeat )
	local parentFrame = getParentFrame( self )
	local parentFocus = parentFrame and parentFrame.focus
	if ( key == "tab" and ( self.focus or parentFocus ) ) then
		gui.frame.moveFocus( self.panel )
	end

	return gui.panel.keypressed( self, key, scancode, isrepeat )
end

function scrollablepanel:setWidth( width )
	self.panel:setWidth( width )
	gui.panel.setWidth( self, width )
end

function scrollablepanel:setHeight( height )
	self.scrollbar:setRangeWindow( height )
	gui.panel.setHeight( self, height )
end

function scrollablepanel:setInnerHeight( innerHeight )
	self.innerHeight = innerHeight
	self.panel:setHeight( innerHeight )
	self.scrollbar:setRange( 0, innerHeight )
end

function scrollablepanel:wheelmoved( x, y )
	local panel = self:getInnerPanel()
	if ( panel.mouseover or panel:isChildMousedOver() ) then
		local scrollbar = self:getScrollbar()
		if ( scrollbar ) then
			local font = self:getScheme( "font" )
			if ( y < 0 ) then
				gui.setFocusedPanel( nil, false )
				scrollbar:scrollDown( 3 * font:getHeight() )
				return true
			elseif ( y > 0 ) then
				gui.setFocusedPanel( nil, false )
				scrollbar:scrollUp( 3 * font:getHeight() )
				return true
			end
		end
	end

	return gui.panel.wheelmoved( self, x, y )
end
