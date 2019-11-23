--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Box class
-- https://www.w3.org/TR/CSS21/box.html#box-dimensions
--
--==========================================================================--

require( "engine.client.gui.panel" )

class "gui.box" ( "gui.panel" )

require( "engine.client.gui.box.properties" )

local function applyProps( panel, props )
	table.foreach( props, function( k, v )
		-- Apply styles
		if ( k == "styles" ) then
			applyProps( panel, v )
			return
		end

		-- Modify key for mutator
		local callback = string.find( k, "^on%u" )
		if ( not callback ) then
			k = "set" .. string.capitalize( k )
		end

		-- Set nil
		if ( v == "nil" ) then
			v = nil
		end

		-- Apply callback or call mutator
		if ( callback ) then
			panel[ k ] = v
		else
			panel[ k ]( panel, v )
		end
	end )
end

function gui.createElement( type, props, children )
	local panel = gui[ type ]()

	if ( props ) then
		applyProps( panel, props )
	end

	if ( children ) then
		for _, v in ipairs( children ) do
			v:setParent( panel )
		end
	end

	return panel
end

local box = gui.box

function box:box( parent, name )
	gui.panel.panel( self, parent, name )

	self:setScheme( "Default" )

	self.props = {
		style    = {},
		children = {}
	}

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

	if ( props ) then
		for k, v in pairs( props ) do
			self.props[ k ] = v
		end
	end

	if ( children ) then
		self.props.children = children
	end
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
	local width, height = self:getDimensions()
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
		v:createCanvas()
	end

	local formattingContext = self:getFormattingContext()

	local x = self:getBorderLeftWidth() +
	          self:getPaddingLeft()
	local y = self:getBorderTopWidth() +
	          self:getPaddingTop()

	for i, v in ipairs( children ) do
		x, y = self:drawChild( i, v, formattingContext, x, y )
	end
end

function box:drawChild( i, v, formattingContext, x, y )
	love.graphics.push()

	-- 9.4 Normal flow
	local position = v:getPosition()

	if ( position == "static" ) then
		-- 9.4.1 Block formatting contexts
		if ( formattingContext == "block" ) then
			if ( i == 1 ) then
				y = y + v:getMarginTop()
			end
		end

		-- 9.4.2 Inline formatting contexts
		if ( formattingContext == "inline" ) then
			x = x + v:getMarginLeft()
		end
	end

	local rx = 0
	local ry = 0

	-- 9.4.3 Relative positioning
	if ( position == "relative" ) then
		rx = self:getLeft()
		ry = self:getTop()
	end

	local ax = self:getX()
	local ay = self:getY()

	-- 9.6 Absolute positioning
	if ( position == "absolute" ) then
		v:setOffsetLeft( nil )
		v:setOffsetTop( nil )

		-- love.graphics.translate( ax, ay )
	else
		local dx = x + rx
		local dy = y + ry

		if ( formattingContext == "block" ) then
			dx = dx + v:getMarginLeft()
		end

		if ( formattingContext == "inline" ) then
			dy = dy + v:getMarginTop()
		end

		v:setOffsetLeft( dx )
		v:setOffsetTop( dy )

		love.graphics.translate( dx, dy )
	end

	v:preDraw()
	v:drawCanvas()
	v:postDraw()

	if ( position == "static" ) then
		if ( formattingContext == "block" ) then
			y = y + v:getHeight()

			-- Vertical margins between adjacent
			-- block-level boxes in a block formatting
			-- context collapse.
			local marginBottom = v:getMarginBottom()
			local sibling = v:getNextSibling()
			if ( sibling ) then
				marginBottom = math.max(
					marginBottom, sibling:getMarginTop()
				)
			end
			y = y + marginBottom
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
	local width, height = self:getDimensions()
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
		if ( v.getDisplay == nil ) then
			error( "attempt to return formatting context for panel '"
				.. tostring( v ) ..
			"'" )
		end

		if ( v:getDisplay() == "block" ) then
			return "block"
		end
	end

	return "inline"
end

function box:getOffsetWidth()
	local children = self:getChildren()

	local formattingContext = self:getFormattingContext()

	local w = self:getBorderLeftWidth() +
	          self:getPaddingLeft()

	local maxWidth = 0
	if ( children ) then
		for i, v in ipairs( children ) do
			if ( formattingContext == "block" ) then
				local w = 0
				w = w + v:getMarginLeft()
				w = w + v:getWidth()
				w = w + v:getMarginRight()
				maxWidth = math.max( maxWidth, w )
			end

			if ( formattingContext == "inline" ) then
				w = w + v:getMarginLeft()
				w = w + v:getWidth()

				local marginRight = v:getMarginRight()
				local sibling = children[ i + 1 ]
				if ( sibling ) then
					marginRight = math.max(
						marginRight, sibling:getMarginLeft()
					)
				end
				w = w + marginRight
			end
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
		for i, v in ipairs( children ) do
			if ( formattingContext == "block" ) then
				h = h + v:getMarginTop()
				h = h + v:getHeight()

				local marginBottom = v:getMarginBottom()
				local sibling = children[ i + 1 ]
				if ( sibling ) then
					marginBottom = math.max(
						marginBottom, sibling:getMarginTop()
					)
				end
				h = h + marginBottom
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
