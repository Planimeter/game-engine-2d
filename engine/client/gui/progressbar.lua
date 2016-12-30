--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Progress Bar class
--
--============================================================================--

class "gui.progressbar" ( "gui.panel" )

function progressbar:progressbar( parent, name )
	gui.panel.panel( self, parent, name )
	self.width    = point( 216 )
	self.height   = point( 2 )
	self.min      = 0
	self.max      = 1
	self.value    = 0

	self:setScheme( "Default" )
end

function progressbar:draw()
	self:drawBackground( "progressbar.backgroundColor" )
	self:drawForeground()

	gui.panel.draw( self )
end

function progressbar:drawForeground()
	local color   = "progressbar.foregroundColor"
	local value   = self:getValue()
	local min     = self:getMin()
	local max     = self:getMax()
	local percent = math.remap( value, min, max, 0, 1 )
	local width   = self:getWidth() * percent
	local height  = self:getHeight()
	graphics.setColor( self:getScheme( color ) )
	graphics.rectangle( "fill", 0, 0, width, height )
end

accessor( progressbar, "min" )
accessor( progressbar, "max" )
accessor( progressbar, "value" )

function progressbar:setMin( min )
	self.min = min
	self:invalidate()
end

function progressbar:setMax( max )
	self.max = max
	self:invalidate()
end

function progressbar:setValue( value )
	self.value = value
	self:invalidate()
end


