--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Tabbed Frame class
--
--============================================================================--

class "tabbedframe" ( gui.frame )

local utf8upper = string.utf8upper

function tabbedframe:tabbedframe( parent, name, title )
	gui.frame.frame( self, parent, name, title )

	local padding   = 24
	local iconWidth = 16
	local x         = self.width - 2 * padding - iconWidth
	local y         = 1
	self.closeButton:setPos( x, y )

	local width     = 2 * padding + iconWidth - 1 - 8
	local height    = 2 * padding + iconWidth - 3
	self.closeButton:setSize( width, height )

	local font             = self:getScheme( "titleFont" )
	local titleWidth       = font:getWidth( utf8upper( self.title ) )
	local closeButtonWidth = self.closeButton:getWidth()
	self.minWidth  = 2 * padding + titleWidth + closeButtonWidth
	self.minHeight = 62

	self.tabGroup  = gui.frametabgroup( self, name .. " Frame Tab Group" )
	self.tabGroup:setPos( 2 * padding + titleWidth, 1 )

	self.tabPanels = gui.frametabpanels( self, name .. " Frame Tab Panels" )
	self.tabPanels:setY( self.minHeight )
end

function tabbedframe:addTab( tabName, tabPanel, default )
	self.tabGroup:addTab( tabName, default )
	self.tabPanels:addPanel( tabPanel, default )

	local padding          = 24
	local font             = self:getScheme( "titleFont" )
	local titleWidth       = font:getWidth( utf8upper( self.title ) )
	local closeButtonWidth = self.closeButton:getWidth()
	local tabGroupWidth    = self.tabGroup:getWidth()
	self:setMinWidth( 3 * padding + titleWidth + tabGroupWidth + closeButtonWidth + 1 + 8 )
	tabPanel:invalidateLayout()
end

function tabbedframe:drawBackground()
	if ( not self.tabPanels:getChildren() ) then
		local width  = self:getWidth()
		local height = self:getHeight()
		graphics.setColor( self:getScheme( "frame.backgroundColor" ) )
		graphics.rectangle( "fill", 0, 62, width, height - 62 )
	end

	-- Title Bar
	graphics.setColor( self:getScheme( "frametab.backgroundColor" ) )
	local padding    = 24
	local font       = self:getScheme( "titleFont" )
	local titleWidth = font:getWidth( utf8upper( self.title ) )
	local w          = 2 * padding + titleWidth + 1
	graphics.rectangle( "fill", 0, 0, w, 62 )

	-- Title Bar Inner Shadow
	graphics.setColor( self:getScheme( "frametab.outlineColor" ) )
	graphics.line( 0, 62 - 1, w, 62 - 1 )

	-- Top Resize Bounds
	graphics.setColor( self:getScheme( "frametab.backgroundColor" ) )
	w = 2 * padding + titleWidth + self.tabGroup:getWidth()
	graphics.line( titleWidth, 0, w, 0 )

	-- Remaining Title Bar
	local r = self:getWidth() - w + 1
	graphics.rectangle( "fill", w - 1, 0, r, 62 )

	-- Remaining Title Bar Inner Shadow
	graphics.setColor( self:getScheme( "frametab.outlineColor" ) )
	graphics.line( w - 1, 62 - 1, w + r, 62 - 1 )
end

function tabbedframe:drawTitle()
	local property = "frame.titleTextColor"
	if ( not self.focus ) then
		property = "frame.defocus.titleTextColor"
	end
	graphics.setColor( self:getScheme( property ) )
	local font = self:getScheme( "titleFont" )
	graphics.setFont( font )
	local padding = 24
	local x       = padding
	local y       = x - 4
	graphics.print( utf8upper( self.title ), x, y )
end

function tabbedframe:getTabGroup()
	return self.tabGroup
end

function tabbedframe:getTabPanels()
	return self.tabPanels
end

function tabbedframe:invalidateLayout()
	local padding   = 24
	local iconWidth = 16
	if ( self.closeButton ) then
		self.closeButton:setX( self:getWidth() - 2 * padding - iconWidth )
	end

	local font       = self:getScheme( "titleFont" )
	local titleWidth = font:getWidth( utf8upper( self.title ) )

	self.tabGroup:setPos( 2 * padding + titleWidth, 1 )
	self.tabPanels:setSize( self:getWidth(), self:getHeight() - 62 )

	gui.panel.invalidateLayout( self )
end

local localX, localY   = 0, 0
local mouseIntersects  = false
local pointinrectangle = math.pointinrectangle

function tabbedframe:mousepressed( x, y, button )
	gui.panel.mousepressed( self, x, y, button )

	if ( not ( button == "wd" or button == "wu" ) ) then
		if ( self.mouseover or self:isChildMousedOver() ) then
			self.mousedown = self.mouseover

			if ( not self:isTopMostChild() ) then
				self:moveToFront()
				self:setFocusedFrame( true )
			end
		else
			self:setFocusedFrame( false )
		end
	end

	if ( self.mousedown and button == "l" ) then
		localX, localY = self:screenToLocal( x, y )
		self.grabbedX  = localX
		self.grabbedY  = localY

		if ( self:isResizable() ) then
			local width  = self:getWidth()
			local height = self:getHeight()

			-- Top Resize Bounds
			mouseIntersects = pointinrectangle(
				localX,
				localY,
				8,
				0,
				width - 16,
				8
			)
			if ( mouseIntersects ) then
				self.resizing = "top"
				return
			end

			-- Top-Right Resize Bounds
			mouseIntersects = pointinrectangle(
				localX,
				localY,
				width - 8,
				0,
				8,
				8
			)
			if ( mouseIntersects ) then
				self.resizing = "topright"
				return
			end

			-- Right Resize Bounds
			mouseIntersects = pointinrectangle(
				localX,
				localY,
				width  - 8,
				8,
				8,
				height - 16
			)
			if ( mouseIntersects ) then
				self.resizing = "right"
				return
			end

			-- Bottom-Right Resize Bounds
			mouseIntersects = pointinrectangle(
				localX,
				localY,
				width  - 8,
				height - 8,
				8,
				8
			)
			if ( mouseIntersects ) then
				self.resizing = "bottomright"
				return
			end

			-- Bottom Resize Bounds
			mouseIntersects = pointinrectangle(
				localX,
				localY,
				8,
				height - 8,
				width  - 16,
				8
			)
			if ( mouseIntersects ) then
				self.resizing = "bottom"
				return
			end

			-- Bottom-Left Resize Bounds
			mouseIntersects = pointinrectangle(
				localX,
				localY,
				0,
				height - 8,
				8,
				8
			)
			if ( mouseIntersects ) then
				self.resizing = "bottomleft"
				return
			end

			-- Left Resize Bounds
			mouseIntersects = pointinrectangle(
				localX,
				localY,
				0,
				8,
				8,
				height - 16
			)
			if ( mouseIntersects ) then
				self.resizing = "left"
				return
			end

			-- Top-Left Resize Bounds
			mouseIntersects = pointinrectangle(
				localX,
				localY,
				0,
				0,
				8,
				8
			)
			if ( mouseIntersects ) then
				self.resizing = "topleft"
				return
			end
		end

		-- Title Bar Resize Bounds
		mouseIntersects = pointinrectangle(
			localX,
			localY,
			0,
			0,
			self:getWidth(),
			62
		)
		if ( mouseIntersects ) then
			self.moving = true
		end
	end
end

gui.register( tabbedframe, "tabbedframe" )
