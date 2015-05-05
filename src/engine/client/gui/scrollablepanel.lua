--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Scrollable Panel class
--
--============================================================================--

class "scrollablepanel" ( gui.panel )

function scrollablepanel:scrollablepanel( parent, name )
	gui.panel.panel( self, parent, name )
	self.panel     = gui.panel( self, self:getName() .. " Inner Panel" )
	self.scrollbar = gui.scrollbar( self, self:getName() .. " Scrollbar" )
	self.scrollbar.onValueChanged = function( _, oldValue, newValue )
		self.panel:setY( -newValue )
	end

	self:setScheme( "Default" )
end

function scrollablepanel:getInnerHeight()
	return self.innerHeight
end

function scrollablepanel:getInnerPanel()
	return self.panel
end

function scrollablepanel:getScrollbar()
	return self.scrollbar
end

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

function scrollablepanel:keypressed( key, isrepeat )
	if ( not self:isVisible() ) then
		return
	end

	local parentFrame = getParentFrame( self )
	local parentFocus = parentFrame and parentFrame.focus
	if ( key == "tab" and ( self.focus or parentFocus ) ) then
		gui.frame.moveFocus( self.panel )
	end

	return gui.panel.keypressed( self, key, isrepeat )
end

local function parentFrameHasFocus( self )
	local parent = self:getParent()
	while ( parent ~= nil ) do
		if ( typeof( parent, "frame" ) ) then
			return parent.focus == true
		end
		parent = parent:getParent()
	end
	return false
end

function scrollablepanel:mousepressed( x, y, button )
	if ( not self:isVisible() ) then
		return
	end

	local panel = self:getInnerPanel()
	if ( panel.mouseover or panel:isChildMousedOver() ) then
		local scrollbar = self:getScrollbar()
		if ( scrollbar and parentFrameHasFocus( self ) ) then
			local font = self:getScheme( "font" )
			if ( button == "wd" ) then
				gui.setFocusedPanel( nil, false )
				scrollbar:scrollDown( 3 * font:getHeight() )
			elseif ( button == "wu" ) then
				gui.setFocusedPanel( nil, false )
				scrollbar:scrollUp( 3 * font:getHeight() )
			end
		end
	end

	gui.panel.mousepressed( self, x, y, button )
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

gui.register( scrollablepanel, "scrollablepanel" )
