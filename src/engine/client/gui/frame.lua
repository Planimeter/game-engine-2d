--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Frame class
--
--============================================================================--

local gui_draw_frame_focus = convar( "gui_draw_frame_focus", "0", nil, nil,
                             "Draws bounds around the focused frame" )

class "frame" ( gui.panel )

local utf8upper = string.utf8upper

function frame:frame( parent, name, title )
	gui.panel.panel( self, parent, name )
	self.width         = 640
	self.height        = 480
	self.title         = title or "Frame"
	self.visible       = false
	self.removeOnClose = false
	self.resizable     = true
	self.movable       = true

	self.closeButton = gui.closebutton( self, name .. " Close Button" )
	self.closeButton:setPos( self.width - 2 * 36 - 16, 1 )

	self:setScheme( "Default" )

	local font             = self:getScheme( "titleFont" )
	local titleWidth       = font:getWidth( utf8upper( self.title ) )
	local closeButtonWidth = self.closeButton:getWidth()
	self.minWidth  = 2 * 36 + titleWidth + closeButtonWidth
	self.minHeight = 86

	self:setUseFullscreenFramebuffer( true )
end

local FRAME_ANIM_SCALE = 0.93
local FRAME_ANIM_TIME  = 0.2

function frame:activate()
	if ( not self:isVisible() ) then
		self:setOpacity( 0 )
		self:setScale( FRAME_ANIM_SCALE )
		self:animate( {
			opacity = 1,
			scale   = 1
		}, FRAME_ANIM_TIME, "easeOutQuint" )
	end

	self:moveToFront()
	self:setVisible( true )
	self:setFocusedFrame( true )
end

function frame:close()
	if ( self.closing ) then
		return
	end

	self.closing = true

	self:animate( {
		opacity = 0,
		scale   = FRAME_ANIM_SCALE
	}, FRAME_ANIM_TIME, "easeOutQuint", function()
		self:setVisible( false )
		self:setOpacity( 1 )
		self:setScale( 1 )

		self.closing = nil

		if ( self:shouldRemoveOnClose() ) then
			self:remove()
		end
	end )
end

function frame:doModal()
	self:setResizable( false )
	self:setMovable( false )

	if ( self.closeButton ) then
		self.closeButton:remove()
		self.closeButton = nil
	end
end

function frame:draw()
	if ( not self:isVisible() ) then
		return
	end

	self:drawBackground()

	gui.panel.draw( self )

	self:drawTitle()
	self:drawForeground()

	if ( gui_draw_frame_focus:getBoolean() and self.focus ) then
		self:drawBounds()
	end
end

function frame:drawBackground()
	graphics.setColor( self:getScheme( "frame.backgroundColor" ) )
	graphics.rectangle( "fill", 0, 0, self:getWidth(), self:getHeight() )
end

function frame:drawForeground()
	graphics.setColor( self:getScheme( "frame.outlineColor" ) )
	graphics.setLineWidth( 1 )
	graphics.rectangle( "line", 0, 0, self:getWidth(), self:getHeight() )
end

function frame:drawTitle()
	local property = "frame.titleTextColor"
	if ( not self.focus ) then
		property = "frame.defocus.titleTextColor"
	end
	graphics.setColor( self:getScheme( property ) )
	local font = self:getScheme( "titleFont" )
	graphics.setFont( font )
	local x = 36
	local y = x - 4
	graphics.print( utf8upper( self.title ), x, y )
end

function frame:getMinWidth()
	return self.minWidth
end

function frame:getMinHeight()
	return self.minHeight
end

function frame:getMinSize()
	return self:getMinWidth(), self:getMinHeight()
end

function frame:getTitle()
	return self.title
end

function frame:invalidateLayout()
	if ( self.closeButton ) then
		self.closeButton:setX( self:getWidth() - 2 * 36 - 16 )
	end

	gui.panel.invalidateLayout( self )
end

function frame:isResizable()
	return self.resizable
end

function frame:isResizing()
	return self.resizing
end

function frame:isMovable()
	return self.movable
end

local function getNextFocusedIndex( children, startpos, endpos, dir )
	if ( dir == -1 ) then
		startpos, endpos = endpos, startpos
	end

	for i = startpos, endpos, dir or 1 do
		if ( children[ i ].canFocus and children[ i ]:isVisible() ) then
			return i
		end
	end
end

function frame:moveFocus()
	local children = self:getChildren()
	if ( children ) then
		local shiftDown    = input.isKeyDown( "lshift", "rshift" )
		local dir          = shiftDown and -1 or nil
		local focusedIndex = nil
		for i, panel in ipairs( children ) do
			if ( panel.focus ) then
				if ( i ~= #children ) then
					local endpos = dir and 1 or #children
					focusedIndex = getNextFocusedIndex( children, i + 1, endpos, dir )
					if ( focusedIndex ) then
						break
					end
				end

				if ( not focusedIndex ) then
					focusedIndex = getNextFocusedIndex( children, 1, i - 1, dir )
					if ( focusedIndex ) then
						break
					end
				end
			end
		end

		if ( not focusedIndex ) then
			focusedIndex = getNextFocusedIndex( children, 1, #children, dir )
		end

		local focusedChild = focusedIndex and children[ focusedIndex ]
		if ( focusedChild ) then
			gui.setFocusedPanel( focusedChild, true )
		end
	end
end

function frame:keypressed( key, isrepeat )
	if ( not self:isVisible() or self.closing ) then
		return
	end

	if ( self.focus ) then
		local controlDown = input.isKeyDown( "lctrl", "rctrl" )
		if ( key == "tab" ) then
			self:moveFocus()
		elseif ( key == "w" and controlDown ) then
			self:close()
		end
	end

	return gui.panel.keypressed( self, key, isrepeat )
end

local localX, localY   = 0, 0
local mouseIntersects  = false
local pointinrectangle = math.pointinrectangle

function frame:mousepressed( x, y, button )
	if ( not self:isVisible() or self.closing ) then
		return
	end

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
			86
		)
		if ( mouseIntersects ) then
			self.moving = true
		end
	end
end

function frame:mousereleased( x, y, button )
	if ( not self:isVisible() or self.closing ) then
		return
	end

	gui.panel.mousereleased( self, x, y, button )

	self.mousedown = false
	self.grabbedX  = nil
	self.grabbedY  = nil
	self.resizing  = nil
	self.moving    = nil

	if ( not self.mouseover ) then
		self:onMouseLeave()
	end
end

function frame:moveToCenter()
	local parent = self:getParent()
	local width  = parent:getWidth()
	local height = parent:getHeight()
	self:setPos( ( width  - self:getWidth() )  / 2,
	             ( height - self:getHeight() ) / 2 )
end

function frame:onLostFocus()
end

function frame:onMouseLeave()
	if ( not self.mousedown ) then
		os.setCursor()
	end
end

function frame:setFocusedFrame( focus )
	local focusedFrame = gui.frame.focusedFrame
	if ( focusedFrame ) then
		focusedFrame.focus = nil
		focusedFrame:onLostFocus()
		focusedFrame:invalidate()
	end

	if ( focus ) then
		gui.frame.focusedFrame = self
		self.focus = focus
		self:invalidate()
	else
		gui.frame.focusedFrame = nil
		self.focus = nil
	end
end

local deltaWidth = 0

function frame:setWidth( width )
	gui.panel.setWidth( self, width )
	if ( self.width < self.minWidth ) then
		deltaWidth = self.minWidth - self.width
		gui.panel.setWidth( self, self.minWidth )
		self:invalidateLayout()
		return deltaWidth
	end
	self:invalidateLayout()
	return 0
end

local deltaHeight = 0

function frame:setHeight( height )
	gui.panel.setHeight( self, height )
	if ( self.height < self.minHeight ) then
		deltaHeight = self.minHeight - self.height
		gui.panel.setHeight( self, self.minHeight )
		self:invalidateLayout()
		return deltaHeight
	end
	self:invalidateLayout()
	return 0
end

function frame:setMinWidth( minWidth )
	self.minWidth = math.round( minWidth )
end

function frame:setMinHeight( minHeight )
	self.minHeight = math.round( minHeight )
end

function frame:setMinSize( minWidth, minHeight )
	self:setMinWidth( minWidth )
	self:setMinHeight( minHeight )
end

function frame:setMovable( movable )
	self.movable = movable
end

function frame:setRemoveOnClose( removeOnClose )
	self.removeOnClose = removeOnClose
end

function frame:setResizable( resizable )
	self.resizable = resizable
end

function frame:setTitle( title )
	self.title = title
end

function frame:shouldRemoveOnClose()
	return self.removeOnClose
end

local mouseX, mouseY   = 0, 0
local getMousePosition = input.getMousePosition
local deltaX, deltaY   = 0, 0

function frame:update( dt )
	gui.panel.update( self, dt )

	if ( not self:isVisible() ) then
		return
	end

	mouseX, mouseY = getMousePosition()
	self:updateCursor( mouseX, mouseY )

	if ( not ( self.grabbedX or self.grabbedY ) ) then
		return
	end

	localX, localY = self:screenToLocal( mouseX, mouseY )
	deltaX, deltaY = localX - self.grabbedX,
	                 localY - self.grabbedY

	if ( deltaX == 0 and deltaY == 0 ) then
		return
	end

	if ( self:isResizable() ) then
		if ( self.resizing == "top" ) then
			deltaHeight   = self:setHeight( self:getHeight() - deltaY )
			self:setY( self:getY() + deltaY - deltaHeight )
			self:invalidateLayout()
		elseif ( self.resizing == "topright" ) then
			deltaWidth    = self:setWidth( self:getWidth()   + deltaX )
			self.grabbedX = localX + deltaWidth
			deltaHeight   = self:setHeight( self:getHeight() - deltaY )
			self:setY( self:getY() + deltaY - deltaHeight )
			self:invalidateLayout()
		elseif ( self.resizing == "right" ) then
			deltaWidth    = self:setWidth( self:getWidth()   + deltaX )
			self.grabbedX = localX + deltaWidth
			self:invalidateLayout()
		elseif ( self.resizing == "bottomright" ) then
			deltaWidth    = self:setWidth( self:getWidth()   + deltaX )
			self.grabbedX = localX + deltaWidth
			deltaHeight   = self:setHeight( self:getHeight() + deltaY )
			self.grabbedY = localY + deltaHeight
			self:invalidateLayout()
		elseif ( self.resizing == "bottom" ) then
			deltaHeight   = self:setHeight( self:getHeight() + deltaY )
			self.grabbedY = localY + deltaHeight
			self:invalidateLayout()
		elseif ( self.resizing == "bottomleft" ) then
			deltaWidth    = self:setWidth( self:getWidth()   - deltaX )
			self:setX( self:getX() + deltaX - deltaWidth )
			deltaHeight   = self:setHeight( self:getHeight() + deltaY )
			self.grabbedY = localY + deltaHeight
			self:invalidateLayout()
		elseif ( self.resizing == "left" ) then
			deltaWidth    = self:setWidth( self:getWidth()   - deltaX )
			self:setX( self:getX() + deltaX - deltaWidth )
			self:invalidateLayout()
		elseif ( self.resizing == "topleft" ) then
			deltaWidth    = self:setWidth( self:getWidth()   - deltaX )
			self:setX( self:getX() + deltaX - deltaWidth )
			deltaHeight   = self:setHeight( self:getHeight() - deltaY )
			self:setY( self:getY() + deltaY - deltaHeight )
			self:invalidateLayout()
		end
	end

	if ( self:isMovable() and self.moving ) then
		self:setX( self:getX() + deltaX )
		self:setY( self:getY() + deltaY )
	end
end

function frame:updateCursor( mouseX, mouseY )
	if ( not self.mouseover or self.mousedown or not self:isResizable() ) then
		return
	end

	localX, localY = self:screenToLocal( mouseX, mouseY )

	-- Top Resize Bounds
	mouseIntersects = pointinrectangle(
		localX,
		localY,
		8,
		0,
		self:getWidth() - 16,
		8
	)
	if ( mouseIntersects and self.mouseover ) then
		os.setCursor( "sizens" )
		return
	end

	-- Top-Right Resize Bounds
	mouseIntersects = pointinrectangle(
		localX,
		localY,
		self:getWidth() - 8,
		0,
		8,
		8
	)
	if ( mouseIntersects ) then
		os.setCursor( "sizenesw" )
		return
	end

	-- Right Resize Bounds
	mouseIntersects = pointinrectangle(
		localX,
		localY,
		self:getWidth()  - 8,
		8,
		8,
		self:getHeight() - 16
	)
	if ( mouseIntersects ) then
		os.setCursor( "sizewe" )
		return
	end

	-- Bottom-Right Resize Bounds
	mouseIntersects = pointinrectangle(
		localX,
		localY,
		self:getWidth()  - 8,
		self:getHeight() - 8,
		8,
		8
	)
	if ( mouseIntersects ) then
		os.setCursor( "sizenwse" )
		return
	end

	-- Bottom Resize Bounds
	mouseIntersects = pointinrectangle(
		localX,
		localY,
		8,
		self:getHeight() - 8,
		self:getWidth()  - 16,
		8
	)
	if ( mouseIntersects ) then
		os.setCursor( "sizens" )
		return
	end

	-- Bottom-Left Resize Bounds
	mouseIntersects = pointinrectangle(
		localX,
		localY,
		0,
		self:getHeight() - 8,
		8,
		8
	)
	if ( mouseIntersects ) then
		os.setCursor( "sizenesw" )
		return
	end

	-- Left Resize Bounds
	mouseIntersects = pointinrectangle(
		localX,
		localY,
		0,
		8,
		8,
		self:getHeight() - 16
	)
	if ( mouseIntersects ) then
		os.setCursor( "sizewe" )
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
		os.setCursor( "sizenwse" )
		return
	end

	os.setCursor()
end

gui.register( frame, "frame" )
