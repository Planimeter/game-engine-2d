--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Label class
--
--============================================================================--

local accessor = accessor
local gui      = gui
local point    = point

class "gui.label" ( "gui.panel" )

local label = gui.label

function label:label( parent, name, text )
	gui.panel.panel( self, parent, name )
	self:setScheme( "Default" )
	self.font      = self:getScheme( "font" )
	self.width     = point( 216 )
	self.height    = self.font:getHeight()
	self.text      = text or "Label"
	self.textAlign = "left"
end

function label:draw()
	graphics.setColor( self:getScheme( "label.textColor" ) )

	local font = self:getFont()
	love.graphics.setFont( font )

	local align     = self:getTextAlign()
	local text      = self:getText()
	local textWidth = font:getWidth( text )
	local x         = 0

	if ( align == "left" ) then
		x = 0
	elseif ( align == "center" ) then
		x = self:getWidth() / 2 - textWidth / 2
	elseif ( align == "right" ) then
		x = self:getWidth() - textWidth + font:getWidth( " " )
	end

	graphics.print( text, x, 0 )

	gui.panel.draw( self )
end

accessor( label, "font" )
accessor( label, "text" )
accessor( label, "textAlign" )

function label:setFont( font )
	self.font = font
	self:invalidate()
end

function label:setText( text )
	self.text = text
	self:invalidate()
end

function label:setTextAlign( textAlign )
	self.textAlign = textAlign
	self:invalidate()
end
