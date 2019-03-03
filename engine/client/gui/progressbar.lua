--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: Progress Bar class
--
--==========================================================================--

class "gui.progressbar" ( "gui.box" )

local progressbar = gui.progressbar

function progressbar:progressbar( parent, name )
	gui.box.box( self, parent, name )
	self:setDisplay( "block" )
	self:setPosition( "absolute" )
	self:setBackgroundColor( self:getScheme( "progressbar.backgroundColor" ) )
	self.width  = 216
	self.height = 2
end

function progressbar:draw()
	gui.panel.drawBackground( self, self:getScheme( "progressbar.backgroundColor" ) )
	self:drawBar()

	gui.box.draw( self )
end

function progressbar:drawBar()
	local color   = self:getScheme( "progressbar.foregroundColor" )
	local value   = self:getValue()
	local min     = self:getMin()
	local max     = self:getMax()
	local percent = math.remap( value, min, max, 0, 1 )
	local width   = self:getWidth() * percent
	local height  = self:getHeight()
	love.graphics.setColor( color )
	love.graphics.rectangle( "fill", 0, 0, width, height )
end

gui.accessor( progressbar, "min",   nil, nil, 0 )
gui.accessor( progressbar, "max",   nil, nil, 1 )
gui.accessor( progressbar, "value", nil, nil, 0 )
