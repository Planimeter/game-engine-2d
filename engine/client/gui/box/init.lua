--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Box class
-- https://www.w3.org/TR/CSS21/box.html#box-dimensions
--
--==========================================================================--

class "gui.box" ( "gui.panel" )

require( "engine.client.gui.box.properties" )

local box = gui.box

function box:box( parent, name )
	gui.panel.panel( self, parent, name )
	self:setScheme( "Default" )

	-- 8.5 Border properties
	-- https://www.w3.org/TR/CSS21/box.html#border-properties
	-- 8.5.1 Border width: 'border-top-width', 'border-right-width',
	-- 'border-bottom-width', 'border-left-width', and 'border-width'
	-- self.borderTopWidth    = "medium"
	-- self.borderRightWidth  = "medium"
	-- self.borderBottomWidth = "medium"
	-- self.borderLeftWidth   = "medium"

	-- 8.5.2 Border color: 'border-top-color', 'border-right-color',
	-- 'border-bottom-color', 'border-left-color', and 'border-color'
	-- self.borderTopColor    = self:getColor()
	-- self.borderRightColor  = self:getColor()
	-- self.borderBottomColor = self:getColor()
	-- self.borderLeftColor   = self:getColor()

	-- 8.5.3 Border style: 'border-top-style', 'border-right-style',
	-- 'border-bottom-style', 'border-left-style', and 'border-style'
	-- self.borderTopStyle    = "none"
	-- self.borderRightStyle  = "none"
	-- self.borderBottomStyle = "none"
	-- self.borderLeftStyle   = "none"
end

function box:preDraw()
	if ( not typeof( self:getParent(), "box" ) ) then
		gui.panel.preDraw( self )
		return
	end

	if ( not self:isVisible() ) then
		return
	end

	local scale = self:getScale()
	local width, height = self:getSize()
	love.graphics.push()

	if ( self:getPosition() == "absolute" ) then
		love.graphics.translate( self:getX(), self:getY() )
	end

	love.graphics.scale( scale )
	love.graphics.translate(
		( width  / scale ) / 2 - width  / 2,
		( height / scale ) / 2 - height / 2
	)
end

function box:draw()
	if ( not self:isVisible() or self:getDisplay() == "none" ) then
		return
	end

	-- self:drawBackground()
	self:drawBorder()

	local children = self:getChildren()
	if ( children == nil ) then
		return
	end

	for _, v in ipairs( children ) do
		v:createFramebuffer()
	end

	local formattingContext = self:getFormattingContext()

	local x = self:getBorderLeftWidth() +
	          self:getPaddingLeft()
	local y = self:getBorderTopWidth() +
	          self:getPaddingTop()

	for _, v in ipairs( children ) do
		x, y = self:drawChild( _, v, formattingContext, x, y )
	end
end

function box:drawChild( _, v, formattingContext, x, y )
	love.graphics.push()

	local position = v:getPosition()

	if ( position == "static" ) then
		if ( formattingContext == "block" ) then
			y = y + v:getMarginTop()
		end

		if ( formattingContext == "inline" ) then
			x = x + v:getMarginLeft()
		end
	end

	if ( position == "static" or position == "relative" ) then
		if ( position == "relative" ) then
			-- TODO: Calculate relative position.
		end

		love.graphics.translate( x, y )
	end

	v:setOffsetLeft( x )
	v:setOffsetTop( y )

	v:preDraw()
	v:drawFramebuffer()
	v:postDraw()

	if ( position == "static" ) then
		if ( formattingContext == "block" ) then
			y = y + v:getHeight()
			y = y + v:getMarginBottom()
		end

		if ( formattingContext == "inline" ) then
			x = x + v:getWidth()
			x = x + v:getMarginRight()
		end
	end

	love.graphics.pop()

	return x, y
end

function box:drawBackground()
	local backgroundColor = self:getBackgroundColor()
	if ( backgroundColor == color.transparent ) then
		return
	end

	gui.panel.drawBackground( self, backgroundColor )
end

function box:drawBorder( color )
	-- TODO: Update border color access.
	-- TODO: Remove color parameter.
	color = color or self:getBorderTopColor() or self:getColor()

	local t, r, b, l = self:getBorderWidth()
	if ( t == 0 and r == 0 and b == 0 and l == 0 ) then
		return
	end

	love.graphics.setColor( color )
	love.graphics.setLineStyle( "rough" )
	love.graphics.setLineWidth( t )
	love.graphics.rectangle(
		"line",
		l / 2,
		t / 2,
		self:getWidth()  - l,
		self:getHeight() - t
	)
end

function box:drawSelection()
	-- Content
	love.graphics.setColor( color.content )
	local t, r, b, l    = self:getPadding()
	local width, height = self:getSize()
	love.graphics.rectangle( "fill", 0, 0, width, height )
	-- love.graphics.rectangle( "fill", l, t, width - l - r, height - t - b )
end

function box:drawName()
end

function box:getScheme( property )
	local base = self
	local status, ret = nil, nil
	while ( base ~= nil ) do
		if ( base.__type ) then
			local p = base.__type .. "." .. property
			status, ret = pcall( scheme.getProperty, self.scheme, p )
			if ( status == true ) then
				return ret
			end
		end

		base = getbaseclass( base )
	end

	status, ret = pcall( scheme.getProperty, self.scheme, property )
	if ( status == true ) then
		return ret
	else
		return nil
	end
end

function box:getFormattingContext()
	local children = self:getChildren()
	if ( children == nil ) then
		return "inline"
	end

	for _, v in ipairs( children ) do
		if ( v:getDisplay() == "block" ) then
			return "block"
		end
	end

	return "inline"
end

function box:getOffsetWidth()
	local children = self:getChildren()

	local w = self:getBorderLeftWidth() +
	          self:getPaddingLeft()

	local maxWidth = 0
	if ( children ) then
		for _, v in ipairs( children ) do
			local w = 0
			w = w + v:getMarginLeft()
			w = w + v:getWidth()
			w = w + v:getMarginRight()
			maxWidth = math.max( maxWidth, w )
		end
	end
	w = w + maxWidth

	w = w + self:getPaddingRight() +
	        self:getBorderRightWidth()

	return w
end

function box:getOffsetHeight()
	local children = self:getChildren()

	local formattingContext = self:getFormattingContext()

	local h = self:getBorderTopWidth() +
	          self:getPaddingTop()

	local maxHeight = 0
	if ( children ) then
		for _, v in ipairs( children ) do
			if ( formattingContext == "block" ) then
				h = h + v:getMarginTop()
				h = h + v:getHeight()
				h = h + v:getMarginBottom()
			end

			if ( formattingContext == "inline" ) then
				local h = 0
				h = h + v:getMarginTop()
				h = h + v:getHeight()
				h = h + v:getMarginBottom()
				maxHeight = math.max( maxHeight, h )
			end
		end
	end
	h = h + maxHeight

	h = h + self:getPaddingBottom() +
	        self:getBorderBottomWidth()

	return h
end
