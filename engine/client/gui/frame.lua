--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: Frame class
--
--==========================================================================--

local gui_draw_frame_focus = convar( "gui_draw_frame_focus", "0", nil, nil,
                             "Draws bounds around the focused frame" )

class "gui.frame" ( "gui.box" )

local frame = gui.frame

function frame:frame( parent, name, title )
	gui.box.box( self, parent, name )
	self:setBorderWidth( 1 )
	self:setPadding( 36 )
	self:setDisplay( "block" )
	self:setPosition( "absolute" )
	self:setBackgroundColor( self:getScheme( "backgroundColor" ) )

	self.width         = 640
	self.height        = 480
	self.title         = title or "Frame"
	self.visible       = false
	self.removeOnClose = false
	self.resizable     = true
	self.movable       = true

	self.closeButton = gui.closebutton( self, name .. " Close Button" )
	local margin     = 36
	self.closeButton:setPos(
		self.width - 2 * margin - 16,
		1
	)

	self:setScheme( "Default" )

	local font             = self:getScheme( "titleFont" )
	local titleWidth       = font:getWidth( self:getTitle() )
	local closeButtonWidth = self.closeButton:getWidth()
	self.minWidth          = 2 * margin + titleWidth + closeButtonWidth
	local titleBarHeight   = 86
	self.minHeight         = titleBarHeight

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
	self.modal = true
	self:setResizable( false )
	self:setMovable( false )

	if ( self.closeButton ) then
		self.closeButton:remove()
		self.closeButton = nil
	end
end

function frame:draw()
	self:drawBackground()

	gui.panel.draw( self )

	self:drawTitle()
	self:drawBorder( self:getScheme( "borderColor" ) )

	if ( gui_draw_frame_focus:getBoolean() and self.focus ) then
		self:drawSelection()
	end
end

function frame:drawTitle()
	local color = self:getScheme( "titleTextColor" )
	if ( not self.focus ) then
		color = self:getScheme( "defocus.titleTextColor" )
	end
	love.graphics.setColor( color )
	local font = self:getScheme( "titleFont" )
	love.graphics.setFont( font )
	local margin = 36
	local x = math.round( margin )
	local y = math.round( margin - 4 )
	love.graphics.print( self:getTitle(), x, y )
end

accessor( frame, "minWidth" )
accessor( frame, "minHeight" )

function frame:getMinSize()
	return self:getMinWidth(), self:getMinHeight()
end

accessor( frame, "title" )

function frame:invalidateLayout()
	if ( self.closeButton ) then
		self.closeButton:setX( self:getWidth() - 2 * 36 - 16 )
	end

	gui.panel.invalidateLayout( self )
end

accessor( frame, "resizable", "is" )
accessor( frame, "resizing",  "is" )
accessor( frame, "movable",   "is" )

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

local next = getNextFocusedIndex

function frame:moveFocus()
	local children = self:getChildren()
	if ( children ) then
		local shiftDown    = love.keyboard.isDown( "lshift", "rshift" )
		local dir          = shiftDown and -1 or nil
		local focusedIndex = nil
		for i, panel in ipairs( children ) do
			if ( panel.focus ) then
				if ( i ~= #children ) then
					local endpos = dir and 1 or #children
					focusedIndex = next( children, i + 1, endpos, dir )
					if ( focusedIndex ) then
						break
					end
				end

				if ( focusedIndex == nil ) then
					focusedIndex = next( children, 1, i - 1, dir )
					if ( focusedIndex ) then
						break
					end
				end
			end
		end

		if ( focusedIndex == nil ) then
			focusedIndex = next( children, 1, #children, dir )
		end

		local focusedChild = focusedIndex and children[ focusedIndex ]
		if ( focusedChild ) then
			gui.setFocusedPanel( focusedChild, true )
		end
	end
end

function frame:keypressed( key, scancode, isrepeat )
	if ( self.closing ) then
		return
	end

	if ( self.focus ) then
		local controlDown = love.keyboard.isDown( "lctrl", "rctrl", "lgui", "rgui" )
		if ( key == "tab" ) then
			self:moveFocus()
		elseif ( key == "w" and controlDown ) then
			if ( not self.modal ) then
				self:close()
			end
		end
	end

	return gui.panel.keypressed( self, key, scancode, isrepeat )
end

local localX, localY   = 0, 0
local mouseIntersects  = false
local pointinrect      = math.pointinrect

function frame:mousepressed( x, y, button, istouch )
	if ( self.closing ) then
		return
	end

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
		local titleBarHeight = 86
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

function frame:mousereleased( x, y, button, istouch )
	if ( self.closing ) then
		return
	end

	gui.panel.mousereleased( self, x, y, button, istouch )

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
		love.mouse.setCursor()
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

accessor( frame, "removeOnClose", "should" )

local mouseX, mouseY = 0, 0
local getPosition    = love.mouse.getPosition
local deltaX, deltaY = 0, 0

function frame:update( dt )
	gui.panel.update( self, dt )

	if ( not self:isVisible() ) then
		return
	end

	mouseX, mouseY = getPosition()
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

	localX, localY    = self:screenToLocal( mouseX, mouseY )
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
		local cursor = love.mouse.getSystemCursor( "sizens" )
		love.mouse.setCursor( cursor )
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
		local cursor = love.mouse.getSystemCursor( "sizenesw" )
		love.mouse.setCursor( cursor )
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
		local cursor = love.mouse.getSystemCursor( "sizewe" )
		love.mouse.setCursor( cursor )
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
		local cursor = love.mouse.getSystemCursor( "sizenwse" )
		love.mouse.setCursor( cursor )
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
		local cursor = love.mouse.getSystemCursor( "sizens" )
		love.mouse.setCursor( cursor )
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
		local cursor = love.mouse.getSystemCursor( "sizenesw" )
		love.mouse.setCursor( cursor )
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
		local cursor = love.mouse.getSystemCursor( "sizewe" )
		love.mouse.setCursor( cursor )
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
		local cursor = love.mouse.getSystemCursor( "sizenwse" )
		love.mouse.setCursor( cursor )
		return
	end

	love.mouse.setCursor()
end
