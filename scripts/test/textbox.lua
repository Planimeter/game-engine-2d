--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: Test text box
--
--==========================================================================--

local name = "Text Box Test"

class "gui.textboxtestframe" ( "gui.frame" )

local textboxtestframe = gui.textboxtestframe

function textboxtestframe:textboxtestframe( parent, name, title )
	gui.frame.frame( self, parent, name, title )

	local textbox = gui.textbox( self )

	local margin = love.window.toPixels( 36 )
	local minHeight = self:getMinHeight()
	minHeight = minHeight + textbox:getHeight()
	self:setMinHeight( minHeight + margin )

	local x       = margin
	local y       = love.window.toPixels( 86 ) -- Title Bar Height
	local width   = self:getWidth()
	local height  = self:getHeight()
	width         = width - 2 * margin
	height        = height - y - margin
	textbox:setPos( x, y )
	textbox:setWidth( width )
	textbox:setHeight( height )
	textbox:setMultiline( true )
	self.textbox = textbox

	self:invalidateLayout()
end

function textboxtestframe:invalidateLayout()
	local textbox = self.textbox
	local margin  = love.window.toPixels( 36 )
	local y       = love.window.toPixels( 86 ) -- Title Bar Height
	local width   = self:getWidth()
	local height  = self:getHeight()
	width         = width - 2 * margin
	height        = height - y - margin
	textbox:setWidth( width )
	textbox:setHeight( height )

	gui.frame.invalidateLayout( self )
end

local frame = gui.textboxtestframe( nil, name, name )
frame:setRemoveOnClose( true )
frame:moveToCenter()
frame:activate()
