--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: Tabbed Frame class
--
--==========================================================================--

class "gui.tabbedframe" ( "gui.frame" )

local tabbedframe = gui.tabbedframe

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
	local titleWidth       = font:getWidth( self.title )
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
	local titleWidth       = font:getWidth( self.title )
	local closeButtonWidth = self.closeButton:getWidth()
	local tabGroupWidth    = self.tabGroup:getWidth()
	self:setMinWidth(
		3 * padding
		  + titleWidth
		  + tabGroupWidth
		  + closeButtonWidth
		  + 1
		  + 8
	)
	tabPanel:invalidateLayout()
end

function tabbedframe:drawBackground()
	local color          = self:getScheme( "frame.backgroundColor" )
	local titleBarHeight = 62
	local width          = self:getWidth()
	local height         = self:getHeight()

	if ( not self.tabPanels:getChildren() ) then
		love.graphics.setColor( color )
		love.graphics.rectangle(
			"fill",
			0,
			titleBarHeight,
			width,
			height - titleBarHeight
		)
	end

	-- Title Bar
	color = self:getScheme( "frametab.backgroundColor" )
	love.graphics.setColor( color )
	local padding    = 24
	local font       = self:getScheme( "titleFont" )
	local titleWidth = font:getWidth( self:getTitle() )
	titleWidth       = 2 * padding + titleWidth
	love.graphics.rectangle( "fill", 0, 0, titleWidth + 1, titleBarHeight )

	-- Title Bar Inner Shadow
	color = self:getScheme( "frametab.borderColor" )
	love.graphics.setColor( color )
	love.graphics.setLineStyle( "rough" )
	local lineWidth = 1
	love.graphics.setLineWidth( lineWidth )
	local y = titleBarHeight - lineWidth / 2
	love.graphics.line(
		0,          y, -- Bottom-left
		titleWidth, y  -- Bottom-right
	)

	-- Top Resize Bounds
	love.graphics.setColor( self:getScheme( "frametab.backgroundColor" ) )
	local x = titleWidth + self.tabGroup:getWidth()
	love.graphics.line(
		titleWidth, lineWidth / 2, -- Top-left
		x,          lineWidth / 2  -- Top-right
	)

	-- Remaining Title Bar
	local r = self:getWidth() - x
	love.graphics.rectangle( "fill", x, 0, r, titleBarHeight )

	-- Remaining Title Bar Inner Shadow
	love.graphics.setColor( self:getScheme( "frametab.borderColor" ) )
	love.graphics.line(
		x,     y, -- Bottom-left
		x + r, y  -- Bottom-right
	)
end

function tabbedframe:drawTitle()
	local color = self:getScheme( "frame.titleTextColor" )
	if ( not self.focus ) then
		color = self:getScheme( "frame.defocus.titleTextColor" )
	end
	love.graphics.setColor( color )
	local font = self:getScheme( "titleFont" )
	love.graphics.setFont( font )
	local margin = 24
	local x = math.round( margin )
	local y = math.round( margin - 4 )
	love.graphics.print( self:getTitle(), x, y )
end

accessor( tabbedframe, "tabGroup" )
accessor( tabbedframe, "tabPanels" )

function tabbedframe:invalidateLayout()
	local padding   = 24
	local iconWidth = 16
	if ( self.closeButton ) then
		self.closeButton:setX( self:getWidth() - 2 * padding - iconWidth )
	end

	local font       = self:getScheme( "titleFont" )
	local titleWidth = font:getWidth( self.title )

	self.tabGroup:setPos( 2 * padding + titleWidth, 1 )
	self.tabPanels:setSize( self:getWidth(), self:getHeight() - 62 )

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
			local borderWidth = 8
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
		local titleBarHeight = 62
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
