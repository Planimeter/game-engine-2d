--=========== Copyright © 2017, Planimeter, All rights reserved. ===========--
--
-- Purpose: Slider class
--
--==========================================================================--

class "gui.slider" ( "gui.scrollbar" )

local slider = gui.slider

function slider:slider( parent, name )
	gui.scrollbar.scrollbar( self, parent, name )
	self.width    = point( 216 )
	self.height   = point( 46 )
	self.minLabel = "Min"
	self.maxLabel = "Max"
	self:setMax( 100 )
end

function slider:draw()
	self:drawTrough()
	self:drawLabels()
	self:drawThumb()

	gui.panel.draw( self )
end

function slider:drawLabels()
	local color = "slider.fontColor"

	if ( self:isDisabled() ) then
		color = "slider.disabled.fontColor"
	end

	love.graphics.setColor( self:getScheme( color ) )
	local font = self:getScheme( "fontSmall" )
	love.graphics.setFont( font )
	local minLabel = self:getMinLabel()
	local maxLabel = self:getMaxLabel()
	local height   = self:getHeight()
	local width    = self:getWidth()
	local x        = width - font:getWidth( maxLabel )
	graphics.print( minLabel, 0, height / 2 + point( 9 ) )
	graphics.print( maxLabel, x, height / 2 + point( 9 ) )
end

function slider:drawThumb()
	local color  = "scrollbar.backgroundColor"
	local height = self:getHeight()
	local y      = 0

	if ( self:isDisabled() ) then
		color = "scrollbar.disabled.backgroundColor"
	end

	love.graphics.setColor( self:getScheme( color ) )
	love.graphics.rectangle( "fill", self:getThumbPos(), y, point( 4 ), height / 2 )
end

function slider:drawTrough()
	local color  = "slider.backgroundColor"
	local height = self:getHeight()
	local width  = self:getWidth()

	if ( self:isDisabled() ) then
		color = "slider.disabled.backgroundColor"
	end

	love.graphics.setColor( self:getScheme( color ) )
	love.graphics.setLineWidth( point( 1 ) )
	love.graphics.line( 0, height / 4, width, height / 4 )
end

accessor( slider, "minLabel" )
accessor( slider, "maxLabel" )

function slider:getThumbLength()
	local range = self:getMax() - self:getMin()
	local size  = self:getRangeWindow() / range
	return size * ( self:getWidth() - point( 4 ) )
end

function slider:getThumbPos()
	local min     = self:getMin()
	local range   = self:getMax() - min
	local percent = ( self:getValue() + min ) / range
	return percent * ( self:getWidth() - point( 4 ) )
end

slider.invalidateLayout = gui.panel.invalidateLayout

function slider:setMinLabel( minLabel )
	self.minLabel = minLabel
	self:invalidate()
end

function slider:setMaxLabel( maxLabel )
	self.maxLabel = maxLabel
	self:invalidate()
end

local localX, localY = 0, 0

function slider:mousepressed( x, y, button, istouch )
	if ( self.mouseover and button == 1 ) then
		self.mousedown = true
	end

	if ( self.mousedown and button == 1 ) then
		localX, localY = self:screenToLocal( x, y )

		if ( localX < self:getThumbPos() ) then
			self:pageUp()
			return
		elseif ( localX > self:getThumbPos() + point( 4 ) ) then
			self:pageDown()
			return
		end

		self.grabbedX  = localX
		self.grabbedY  = localY
	end
end

local mouseX, mouseY = 0, 0
local getPosition    = love.mouse.getPosition
local deltaX, deltaY = 0, 0
local min, max       = 0, 0

function slider:update( dt )
	gui.panel.update( self, dt )

	if ( not self:isVisible() or self:isDisabled() ) then
		return
	end

	if ( not ( self.grabbedX or self.grabbedY ) ) then
		return
	end

	mouseX, mouseY = getPosition()
	localX, localY = self:screenToLocal( mouseX, mouseY )
	deltaX, deltaY = localX - self.grabbedX,
	                 localY - self.grabbedY

	if ( deltaX == 0 and deltaY == 0 ) then
		return
	end

	min, max      = self:getRange()
	range         = max - min
	deltaValue    = ( deltaX / self:getWidth() ) * range
	deltaValue    = self:setValue( self:getValue() + deltaValue )
	self.grabbedX = localX + ( deltaValue / range ) * self:getWidth()
	self.grabbedY = localY
end
