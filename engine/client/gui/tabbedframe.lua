--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Tabbed Frame class
--
--============================================================================--

class "gui.tabbedframe" ( "gui.frame" )

local utf8upper = string.utf8upper

function tabbedframe:tabbedframe( parent, name, title )
	gui.frame.frame( self, parent, name, title )

	local padding   = point( 24 )
	local iconWidth = point( 16 )
	local x         = self.width - 2 * padding - iconWidth
	local y         = point( 1 )
	self.closeButton:setPos( x, y )

	local width     = 2 * padding + iconWidth - point( 1 ) - point( 8 )
	local height    = 2 * padding + iconWidth - point( 3 )
	self.closeButton:setSize( width, height )

	local font             = self:getScheme( "titleFont" )
	local titleWidth       = font:getWidth( utf8upper( self.title ) )
	local closeButtonWidth = self.closeButton:getWidth()
	self.minWidth  = 2 * padding + titleWidth + closeButtonWidth
	self.minHeight = point( 62 )

	self.tabGroup  = gui.frametabgroup( self, name .. " Frame Tab Group" )
	self.tabGroup:setPos( 2 * padding + titleWidth, point( 1 ) )

	self.tabPanels = gui.frametabpanels( self, name .. " Frame Tab Panels" )
	self.tabPanels:setY( self.minHeight )
end

function tabbedframe:addTab( tabName, tabPanel, default )
	self.tabGroup:addTab( tabName, default )
	self.tabPanels:addPanel( tabPanel, default )

	local padding          = point( 24 )
	local font             = self:getScheme( "titleFont" )
	local titleWidth       = font:getWidth( utf8upper( self.title ) )
	local closeButtonWidth = self.closeButton:getWidth()
	local tabGroupWidth    = self.tabGroup:getWidth()
	self:setMinWidth(
		3 * padding
		  + titleWidth
		  + tabGroupWidth
		  + closeButtonWidth
		  + point( 1 )
		  + point( 8 )
	)
	tabPanel:invalidateLayout()
end

function tabbedframe:drawBackground()
	local color          = "frame.backgroundColor"
	local titleBarHeight = point( 62 )
	local width          = self:getWidth()
	local height         = self:getHeight()

	if ( not self.tabPanels:getChildren() ) then
		graphics.setColor( self:getScheme( color ) )
		graphics.rectangle(
			"fill",
			0,
			titleBarHeight,
			width,
			height - titleBarHeight
		)
	end

	-- Title Bar
	color = "frametab.backgroundColor"
	graphics.setColor( self:getScheme( color ) )
	local padding    = point( 24 )
	local font       = self:getScheme( "titleFont" )
	local titleWidth = font:getWidth( utf8upper( self:getTitle() ) )
	titleWidth       = 2 * padding + titleWidth
	graphics.rectangle( "fill", 0, 0, titleWidth + point( 1 ), titleBarHeight )

	-- Title Bar Inner Shadow
	color = "frametab.outlineColor"
	graphics.setColor( self:getScheme( color ) )
	local lineWidth = point( 1 )
	graphics.setLineWidth( lineWidth )
	local y = titleBarHeight - lineWidth / 2
	love.graphics.line(
		0,          y, -- Bottom-left
		titleWidth, y  -- Bottom-right
	)

	-- Top Resize Bounds
	graphics.setColor( self:getScheme( "frametab.backgroundColor" ) )
	local x = titleWidth + self.tabGroup:getWidth()
	love.graphics.line(
		titleWidth, lineWidth / 2, -- Top-left
		x,          lineWidth / 2  -- Top-right
	)

	-- Remaining Title Bar
	local r = self:getWidth() - titleWidth
	graphics.rectangle( "fill", x, 0, r, titleBarHeight )

	-- Remaining Title Bar Inner Shadow
	graphics.setColor( self:getScheme( "frametab.outlineColor" ) )
	love.graphics.line(
		x,     y, -- Bottom-left
		x + r, y  -- Bottom-right
	)
end

function tabbedframe:drawTitle()
	local color = "frame.titleTextColor"
	if ( not self.focus ) then
		color = "frame.defocus.titleTextColor"
	end
	graphics.setColor( self:getScheme( color ) )
	local font = self:getScheme( "titleFont" )
	love.graphics.setFont( font )
	local margin = point( 24 )
	local x = margin
	local y = margin - point( 4 )
	graphics.print( utf8upper( self:getTitle() ), x, y )
end

accessor( tabbedframe, "tabGroup" )
accessor( tabbedframe, "tabPanels" )

function tabbedframe:invalidateLayout()
	local padding   = point( 24 )
	local iconWidth = point( 16 )
	if ( self.closeButton ) then
		self.closeButton:setX( self:getWidth() - 2 * padding - iconWidth )
	end

	local font       = self:getScheme( "titleFont" )
	local titleWidth = font:getWidth( utf8upper( self.title ) )

	self.tabGroup:setPos( 2 * padding + titleWidth, point( 1 ) )
	self.tabPanels:setSize( self:getWidth(), self:getHeight() - point( 62 ) )

	gui.panel.invalidateLayout( self )
end

local localX, localY  = 0, 0
local mouseIntersects = false
local pointinrect     = math.pointinrect

function tabbedframe:mousepressed( x, y, button, istouch )
	if ( gui.panel.mousepressed( self, x, y, button, istouch ) ) then
		return true
	end

	if ( self.mouseover or self:isChildMousedOver() ) then
		self.mousedown = self.mouseover

		if ( not self:isTopMostChild() ) then
			self:moveToFront()
			self:setFocusedFrame( true )
		end
	else
		self:setFocusedFrame( false )
	end

	if ( self.mousedown and button == 1 ) then
		localX, localY = self:screenToLocal( x, y )
		self.grabbedX  = localX
		self.grabbedY  = localY

		if ( self:isResizable() ) then
			local borderWidth = point( 8 )
			local width       = self:getWidth()
			local height      = self:getHeight()

			-- Top Resize Bounds
			mouseIntersects = pointinrect(
				localX,
				localY,
				borderWidth,
				0,
				width - 2 * borderWidth,
				borderWidth
			)
			if ( mouseIntersects ) then
				self.resizing = "top"
				return
			end

			-- Top-Right Resize Bounds
			mouseIntersects = pointinrect(
				localX,
				localY,
				width - borderWidth,
				0,
				borderWidth,
				borderWidth
			)
			if ( mouseIntersects ) then
				self.resizing = "topright"
				return
			end

			-- Right Resize Bounds
			mouseIntersects = pointinrect(
				localX,
				localY,
				width - borderWidth,
				borderWidth,
				borderWidth,
				height - 2 * borderWidth
			)
			if ( mouseIntersects ) then
				self.resizing = "right"
				return
			end

			-- Bottom-Right Resize Bounds
			mouseIntersects = pointinrect(
				localX,
				localY,
				width - borderWidth,
				height - borderWidth,
				borderWidth,
				borderWidth
			)
			if ( mouseIntersects ) then
				self.resizing = "bottomright"
				return
			end

			-- Bottom Resize Bounds
			mouseIntersects = pointinrect(
				localX,
				localY,
				borderWidth,
				height - borderWidth,
				width - 2 * borderWidth,
				borderWidth
			)
			if ( mouseIntersects ) then
				self.resizing = "bottom"
				return
			end

			-- Bottom-Left Resize Bounds
			mouseIntersects = pointinrect(
				localX,
				localY,
				0,
				height - borderWidth,
				borderWidth,
				borderWidth
			)
			if ( mouseIntersects ) then
				self.resizing = "bottomleft"
				return
			end

			-- Left Resize Bounds
			mouseIntersects = pointinrect(
				localX,
				localY,
				0,
				borderWidth,
				borderWidth,
				height - 2 * borderWidth
			)
			if ( mouseIntersects ) then
				self.resizing = "left"
				return
			end

			-- Top-Left Resize Bounds
			mouseIntersects = pointinrect(
				localX,
				localY,
				0,
				0,
				borderWidth,
				borderWidth
			)
			if ( mouseIntersects ) then
				self.resizing = "topleft"
				return
			end
		end

		-- Title Bar Resize Bounds
		local titleBarHeight = point( 62 )
		mouseIntersects = pointinrect(
			localX,
			localY,
			0,
			0,
			self:getWidth(),
			titleBarHeight
		)
		if ( mouseIntersects ) then
			self.moving = true
		end
	end
end


