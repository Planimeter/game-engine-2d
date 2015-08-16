--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Scrollbar class
--
--============================================================================--

class "scrollbar" ( gui.panel )

function scrollbar:scrollbar( parent, name )
	gui.panel.panel( self, parent, name )
	self.width       = 4
	self.height      = parent:getHeight()
	self.disabled    = false
	self.min         = 0
	self.max         = 0
	self.rangeWindow = 0
	self.value       = 0

	self:setScheme( "Default" )
	self:setUseFullscreenFramebuffer( true )
end

function scrollbar:draw()
	local length = self:getThumbLength()
	if ( length == self:getHeight() ) then
		return
	end

	local property = "scrollbar.backgroundColor"
	local width    = self:getWidth()
	local x        = 0

	if ( self:isDisabled() ) then
		property = "scrollbar.disabled.backgroundColor"
	end

	graphics.setColor( self:getScheme( property ) )
	graphics.rectangle( "fill", x, self:getThumbY(), width, length )

	gui.panel.draw( self )
end

function scrollbar:getMin()
	return self.min
end

function scrollbar:getMax()
	return self.max
end

function scrollbar:getRange()
	return self.min, self.max
end

function scrollbar:getRangeWindow()
	return self.rangeWindow
end

function scrollbar:getThumbLength()
	local range = self:getMax() - self:getMin()
	local size  = self:getRangeWindow() / range
	return size * self:getHeight()
end

function scrollbar:getThumbY()
	local min     = self:getMin()
	local range   = self:getMax() - min
	local percent = ( self:getValue() + min ) / range
	return percent * self:getHeight()
end

function scrollbar:getValue()
	return self.value
end

function scrollbar:invalidateLayout()
	local parent = self:getParent()
	self:setPos( parent:getWidth() - self:getWidth(), 0 )
	self:setHeight( parent:getHeight() )
end

function scrollbar:isDisabled()
	return self.disabled
end

local localX, localY = 0, 0

function scrollbar:mousepressed( x, y, button )
	if ( self.mouseover and button == "l" ) then
		self.mousedown = true
	end

	if ( self.mousedown and button == "l" ) then
		localX, localY = self:screenToLocal( x, y )

		if ( localY < self:getThumbY() ) then
			self:pageUp()
			return
		elseif ( localY > self:getThumbY() + self:getThumbLength() ) then
			self:pageDown()
			return
		end

		self.grabbedX  = localX
		self.grabbedY  = localY
	end
end

function scrollbar:mousereleased( x, y, button )
	self.mousedown = false
	self.grabbedX  = nil
	self.grabbedY  = nil
end

function scrollbar:onValueChanged( oldValue, newValue )
end

function scrollbar:pageDown()
	self:scrollDown( self:getRangeWindow() )
end

function scrollbar:pageUp()
	self:scrollUp( self:getRangeWindow() )
end

function scrollbar:scrollDown( value )
	self:setValue( self:getValue() + value )
end

function scrollbar:scrollUp( value )
	self:setValue( self:getValue() - value )
end

function scrollbar:scrollToBottom()
	self:setValue( self:getMax() )
end

function scrollbar:scrollToTop()
	self:setValue( self:getMin() )
end

function scrollbar:setDisabled( disabled )
	self.disabled = disabled
end

local minRange, maxRange = 0, 0
local range              = 0
local newRange           = 0

local function updateRange( self, min, max )
	minRange, maxRange = self:getRange()
	range              = maxRange - minRange
	newRange           = max      - min
	if ( range ~= 0 ) then
		self.value     = ( self:getValue() + self:getMin() ) / range *
		                 newRange + self:getMin()
		if ( self.value > self:getMax() - self:getRangeWindow() ) then
			self.value = self:getMax() - self:getRangeWindow()
		end
	end
end

function scrollbar:setMin( min )
	updateRange( self, min, self:getMax() )
	self.min = min
end

function scrollbar:setMax( max )
	updateRange( self, self:getMin(), max )
	self.max = max
end

function scrollbar:setRange( min, max )
	self:setMin( min )
	self:setMax( max )
end

function scrollbar:setRangeWindow( rangeWindow )
	self.rangeWindow = rangeWindow
	local rangeSize  = self:getMax() - self:getMin()
	if ( rangeWindow > rangeSize ) then
		self.rangeWindow = rangeSize
	end
end

local oldValue   = 0
local deltaValue = 0

function scrollbar:setValue( value )
	oldValue   = self.value
	self.value = value
	if ( self.value < self.min ) then
		deltaValue = self.min - self.value
		self.value = self.min
		self:onValueChanged( oldValue, self.value )
		self:invalidate()
		return deltaValue
	elseif ( self.value > self.max - self.rangeWindow ) then
		deltaValue = self.max - self.rangeWindow - self.value
		self.value = self.max - self.rangeWindow
		self:onValueChanged( oldValue, self.value )
		self:invalidate()
		return deltaValue
	end
	self:onValueChanged( oldValue, self.value )
	self:invalidate()
	return 0
end

local mouseX, mouseY   = 0, 0
local getMousePosition = input.getMousePosition
local deltaX, deltaY   = 0, 0

function scrollbar:update( dt )
	gui.panel.update( self, dt )

	if ( not self:isVisible() or self:isDisabled() ) then
		return
	end

	if ( not ( self.grabbedX or self.grabbedY ) ) then
		return
	end

	mouseX, mouseY = getMousePosition()
	localX, localY = self:screenToLocal( mouseX, mouseY )
	deltaX, deltaY = localX - self.grabbedX,
	                 localY - self.grabbedY

	if ( deltaX == 0 and deltaY == 0 ) then
		return
	end

	minRange, maxRange = self:getRange()
	range              = maxRange - minRange
	deltaValue         = ( deltaY / self:getHeight() ) * range
	deltaValue         = self:setValue( self:getValue() + deltaValue )
	self.grabbedX      = localX
	self.grabbedY      = localY + ( deltaValue / range ) * self:getHeight()
end

gui.register( scrollbar, "scrollbar" )
