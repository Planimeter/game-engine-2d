--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Frame class
--
--============================================================================--

local accessor = accessor
local gui      = gui
local love     = love
local math     = math
local point    = point
local string   = string
local unpack   = unpack

local gui_draw_frame_focus = convar( "gui_draw_frame_focus", "0", nil, nil,
                             "Draws bounds around the focused frame" )

class "gui.frame" ( "gui.panel" )

function _M:frame( parent, name, title )
	gui.panel.panel( self, parent, name )
	self.width         = point( 640 )
	self.height        = point( 480 )
	self.title         = title or "Frame"
	self.visible       = false
	self.removeOnClose = false
	self.resizable     = true
	self.movable       = true

	self.closeButton = gui.closebutton( self, name .. " Close Button" )
	local margin     = point( 36 )
	self.closeButton:setPos(
		self.width - 2 * margin - point( 16 ),
		point( 1 )
	)

	self:setScheme( "Default" )

	local font             = self:getScheme( "titleFont" )
	local titleWidth       = font:getWidth( string.utf8upper( self:getTitle() ) )
	local closeButtonWidth = self.closeButton:getWidth()
	self.minWidth          = 2 * margin + titleWidth + closeButtonWidth
	local titleBarHeight   = point( 86 )
	self.minHeight         = titleBarHeight

	self:setUseFullscreenFramebuffer( true )
end

local FRAME_ANIM_SCALE = 0.93
local FRAME_ANIM_TIME  = 0.2

function _M:activate()
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

function _M:close()
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

function _M:doModal()
	self.modal = true
	self:setResizable( false )
	self:setMovable( false )

	if ( self.closeButton ) then
		self.closeButton:remove()
		self.closeButton = nil
	end
end

function _M:draw()
	self:drawBackground( "frame.backgroundColor" )

	gui.panel.draw( self )

	self:drawTitle()
	self:drawForeground( "frame.outlineColor" )

	if ( gui_draw_frame_focus:getBoolean() and self.focus ) then
		self:drawBounds()
	end
end

function _M:drawTitle()
	local color = "frame.titleTextColor"
	if ( not self.focus ) then
		color = "frame.defocus.titleTextColor"
	end
	love.graphics.setColor( unpack( self:getScheme( color ) ) )
	local font = self:getScheme( "titleFont" )
	love.graphics.setFont( font )
	local margin = point( 36 )
	local x = margin
	local y = margin - point( 4 )
	love.graphics.print( string.utf8upper( self:getTitle() ), x, y )
end

accessor( _M, "minWidth" )
accessor( _M, "minHeight" )

function _M:getMinSize()
	return self:getMinWidth(), self:getMinHeight()
end

accessor( _M, "title" )

function _M:invalidateLayout()
	if ( self.closeButton ) then
		self.closeButton:setX( self:getWidth() - 2 * point( 36 ) - point( 16 ) )
	end

	gui.panel.invalidateLayout( self )
end

function _M:isResizable()
	return self.resizable
end

function _M:isResizing()
	return self.resizing
end

function _M:isMovable()
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

local next = getNextFocusedIndex

function _M:moveFocus()
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

				if ( not focusedIndex ) then
					focusedIndex = next( children, 1, i - 1, dir )
					if ( focusedIndex ) then
						break
					end
				end
			end
		end

		if ( not focusedIndex ) then
			focusedIndex = next( children, 1, #children, dir )
		end

		local focusedChild = focusedIndex and children[ focusedIndex ]
		if ( focusedChild ) then
			gui.setFocusedPanel( focusedChild, true )
		end
	end
end

function _M:keypressed( key, scancode, isrepeat )
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

function _M:mousepressed( x, y, button, istouch )
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
		local titleBarHeight = point( 86 )
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

function _M:mousereleased( x, y, button, istouch )
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

function _M:moveToCenter()
	local parent = self:getParent()
	local width  = parent:getWidth()
	local height = parent:getHeight()
	self:setPos( ( width  - self:getWidth() )  / 2,
	             ( height - self:getHeight() ) / 2 )
end

function _M:onLostFocus()
end

function _M:onMouseLeave()
	if ( not self.mousedown ) then
		love.mouse.setCursor()
	end
end

function _M:setFocusedFrame( focus )
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

function _M:setWidth( width )
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

function _M:setHeight( height )
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

function _M:setMinWidth( minWidth )
	self.minWidth = math.round( minWidth )
end

function _M:setMinHeight( minHeight )
	self.minHeight = math.round( minHeight )
end

function _M:setMinSize( minWidth, minHeight )
	self:setMinWidth( minWidth )
	self:setMinHeight( minHeight )
end

function _M:setMovable( movable )
	self.movable = movable
end

function _M:setRemoveOnClose( removeOnClose )
	self.removeOnClose = removeOnClose
end

function _M:setResizable( resizable )
	self.resizable = resizable
end

function _M:shouldRemoveOnClose()
	return self.removeOnClose
end

local mouseX, mouseY = 0, 0
local getPosition    = love.mouse.getPosition
local deltaX, deltaY = 0, 0

function _M:update( dt )
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

function _M:updateCursor( mouseX, mouseY )
	if ( not self.mouseover or self.mousedown or not self:isResizable() ) then
		return
	end

	localX, localY    = self:screenToLocal( mouseX, mouseY )
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
