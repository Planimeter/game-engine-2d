--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Box properties
--
--==========================================================================--

class "gui.box" ( "gui.panel" )

local box = gui.box

function box.accessor( member, methods )
	member = string.capitalize( member )

	if ( methods ) then
		methods = table.map( methods, function( k, v )
			return string.capitalize( v )
		end )
	else
		methods = {
			member .. "Top",
			member .. "Right",
			member .. "Bottom",
			member .. "Left",
		}
	end

	local setter = "set" .. member
	box[ setter ] = function( self, ... )
		local argc = select( "#", ... )
		if ( argc == 1 ) then
			self[ "set" .. methods[ 1 ] ]( self, select( 1, ... ) )
			self[ "set" .. methods[ 2 ] ]( self, select( 1, ... ) )
			self[ "set" .. methods[ 3 ] ]( self, select( 1, ... ) )
			self[ "set" .. methods[ 4 ] ]( self, select( 1, ... ) )
		elseif ( argc == 2 ) then
			self[ "set" .. methods[ 1 ] ]( self, select( 1, ... ) )
			self[ "set" .. methods[ 2 ] ]( self, select( 2, ... ) )
			self[ "set" .. methods[ 3 ] ]( self, select( 1, ... ) )
			self[ "set" .. methods[ 4 ] ]( self, select( 2, ... ) )
		elseif ( argc == 3 ) then
			self[ "set" .. methods[ 1 ] ]( self, select( 1, ... ) )
			self[ "set" .. methods[ 2 ] ]( self, select( 2, ... ) )
			self[ "set" .. methods[ 3 ] ]( self, select( 3, ... ) )
			self[ "set" .. methods[ 4 ] ]( self, select( 2, ... ) )
		elseif ( argc == 4 ) then
			self[ "set" .. methods[ 1 ] ]( self, select( 1, ... ) )
			self[ "set" .. methods[ 2 ] ]( self, select( 2, ... ) )
			self[ "set" .. methods[ 3 ] ]( self, select( 3, ... ) )
			self[ "set" .. methods[ 4 ] ]( self, select( 4, ... ) )
		end
	end

	local getter = "get" .. member
	box[ getter ] = function( self )
		return self[ "get" .. methods[ 1 ] ]( self ),
		       self[ "get" .. methods[ 2 ] ]( self ),
		       self[ "get" .. methods[ 3 ] ]( self ),
		       self[ "get" .. methods[ 4 ] ]( self )
	end
end

-- 8.3 Margin properties: 'margin-top', 'margin-right', 'margin-bottom',
-- 'margin-left', and 'margin'
-- https://www.w3.org/TR/CSS21/box.html#margin-properties
gui.accessor( box, "marginTop",         nil, nil, 0 )
gui.accessor( box, "marginBottom",      nil, nil, 0 )

gui.accessor( box, "marginRight",       nil, nil, 0 )
gui.accessor( box, "marginLeft",        nil, nil, 0 )

box.accessor( "margin" )

-- 8.4 Padding properties: 'padding-top', 'padding-right', 'padding-bottom',
-- 'padding-left', and 'padding'
-- https://www.w3.org/TR/CSS21/box.html#padding-properties
gui.accessor( box, "paddingTop",        nil, nil, 0 )
gui.accessor( box, "paddingRight",      nil, nil, 0 )
gui.accessor( box, "paddingBottom",     nil, nil, 0 )
gui.accessor( box, "paddingLeft",       nil, nil, 0 )

box.accessor( "padding" )

-- 8.5 Border properties
-- 8.5.1 Border width: 'border-top-width', 'border-right-width',
-- 'border-bottom-width', 'border-left-width', and 'border-width'
gui.accessor( box, "borderTopWidth",    nil, nil, 0 )
gui.accessor( box, "borderRightWidth",  nil, nil, 0 )
gui.accessor( box, "borderBottomWidth", nil, nil, 0 )
gui.accessor( box, "borderLeftWidth",   nil, nil, 0 )

box.accessor( "borderWidth", {
	"borderTopWidth",
	"borderRightWidth",
	"borderBottomWidth",
	"borderLeftWidth"
} )

-- 8.5.2 Border color: 'border-top-color', 'border-right-color',
-- 'border-bottom-color', 'border-left-color', and 'border-color'
gui.accessor( box, "borderTopColor" )
gui.accessor( box, "borderRightColor" )
gui.accessor( box, "borderBottomColor" )
gui.accessor( box, "borderLeftColor" )

box.accessor( "borderColor", {
	"borderTopColor",
	"borderRightColor",
	"borderBottomColor",
	"borderLeftColor"
} )

-- 8.5.3 Border style: 'border-top-style', 'border-right-style',
-- 'border-bottom-style', 'border-left-style', and 'border-style'
gui.accessor( box, "borderTopStyle" )
gui.accessor( box, "borderRightStyle" )
gui.accessor( box, "borderBottomStyle" )
gui.accessor( box, "borderLeftStyle" )

box.accessor( "borderStyle" )

-- 8.5.4 Border shorthand properties: 'border-top', 'border-right',
-- 'border-bottom', 'border-left', and 'border'
-- gui.accessor( box, "borderTop" )
-- gui.accessor( box, "borderRight" )
-- gui.accessor( box, "borderBottom" )
-- gui.accessor( box, "borderLeft" )

-- gui.accessor( box, "border" )

-- 9.2.4 The 'display' property
gui.accessor( box, "display",           nil, nil, "inline" )

-- 9.3.1 Choosing a positioning scheme: 'position' property
gui.accessor( box, "position",          nil, nil, "static" )

-- 9.3.2 Box offsets: 'top', 'right', 'bottom', 'left'
gui.accessor( box, "top",               nil, nil, "auto" )
gui.accessor( box, "right",             nil, nil, "auto" )
gui.accessor( box, "bottom",            nil, nil, "auto" )
gui.accessor( box, "left",              nil, nil, "auto" )

-- 14.1 Foreground color: the 'color' property
gui.accessor( box, "color",             nil, nil, color.black )

-- 14.2 The background
-- 14.2.1 Background properties: 'background-color', 'background-image',
-- 'background-repeat', 'background-attachment', 'background-position', and
-- 'background'
gui.accessor( box, "backgroundColor",   nil, nil, color.transparent )

function box:getBackgroundColor()
	if ( self.backgroundColor ) then
		return self.backgroundColor
	end

	-- :disabled
	local disabled = self.isDisabled and self:isDisabled()
	local style    = self:getScheme( "disabled.backgroundColor" )
	if ( disabled and style ) then
		return style
	end

	-- :active
	local mouseover = self.mouseover or self:isChildMousedOver()
	local active    = self.mousedown and mouseover
	style           = self:getScheme( "mousedown.backgroundColor" )
	if ( active and style ) then
		return style
	end

	-- :hover
	local mouseover = self.mouseover or self:isChildMousedOver()
	local hover = self.mousedown or mouseover
	style       = self:getScheme( "mouseover.backgroundColor" )
	if ( hover and style ) then
		return style
	end

	style = self:getScheme( "backgroundColor" )
	if ( style ) then
		return style
	end

	return color.transparent
end

function box:getX()
	if ( self:getPosition() == "absolute" ) then
		return self.x
	end
	return self:getOffsetLeft()
end

function box:getY()
	if ( self:getPosition() == "absolute" ) then
		return self.y
	end
	return self:getOffsetTop()
end

function box:getWidth()
	return self.width or self:getOffsetWidth()
end

function box:getHeight()
	return self.height or self:getOffsetHeight()
end

accessor( box, "offsetLeft", nil, nil, 0 )
accessor( box, "offsetTop", nil, nil, 0 )
