--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
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
	-- HACKHACK: Fade this out for readability.
	if ( ( g_MainMenu and not g_MainMenu:isVisible() ) and
	     ( g_GameMenu and g_GameMenu:isVisible() ) ) then
		self:setOpacity( 1 - g_GameMenu:getOpacity() )
	else
		self:setOpacity( 1 )
	end

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
