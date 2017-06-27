--=========== Copyright © 2017, Planimeter, All rights reserved. ===========--
--
-- Purpose: Frame Rate class
--
--==========================================================================--

class "gui.framerate" ( "gui.label" )

local framerate = gui.framerate

function framerate:framerate( parent, name )
	gui.label.label( self, parent, name, text )
	self:setTextAlign( "right" )
	self:invalidateLayout()
end

function framerate:update( dt )
	self:setText( self:getFramerate() )
	self:invalidate()
end

function framerate:getFramerate()
	local fps = love.timer.getFPS() .. " FPS"
	local ms  = 1000 * love.timer.getAverageDelta()
	ms        = string.format( "%.3f", ms ) .. " ms"
	return fps .. " / " .. ms
end

function framerate:invalidateLayout()
	local parent = self:getParent()
	local margin = gui.scale( 96 )
	local width  = self:getWidth()
	local height = self:getHeight()
	local x      = parent:getWidth()  - margin - width
	local y      = parent:getHeight() - margin - height
	self:setPos( x, y )

	gui.panel.invalidateLayout( self )
end
