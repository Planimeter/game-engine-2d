--=========== Copyright © 2017, Planimeter, All rights reserved. ===========--
--
-- Purpose: Command Button Group class
--
--==========================================================================--

class "gui.commandbuttongroup" ( "gui.panel" )

local commandbuttongroup = gui.commandbuttongroup

function commandbuttongroup:commandbuttongroup( parent, name )
	gui.panel.panel( self, parent, name )
	self.height = love.window.toPixels( 46 )

	self:setScheme( "Default" )
	self:invalidateLayout()
end

function commandbuttongroup:draw()
	gui.panel.draw( self )

	local color  = "commandbuttongroup.outlineColor"
	local width  = self:getWidth()
	local height = self:getHeight()

	love.graphics.setColor( self:getScheme( color ) )
	local lineWidth = love.window.toPixels( 1 )
	love.graphics.setLineWidth( lineWidth )
	love.graphics.line(
		lineWidth / 2,         height,        -- Bottom-left
		lineWidth / 2,         lineWidth / 2, -- Top-left
		width - lineWidth / 2, lineWidth / 2, -- Top-right
		width - lineWidth / 2, height         -- Bottom-right
	)
end

function commandbuttongroup:invalidateLayout()
	local children = self:getChildren()
	local width = 0
	if ( children ) then
		for i, commandbutton in ipairs( children ) do
			commandbutton:setX( width )
			width = width + commandbutton:getWidth()
		end
	end
	self:setWidth( width )

	local parent   = self:getParent()
	local toPixels = love.window.toPixels
	local margin   = typeof( parent, "tabbedframe" ) and toPixels( 24 )
	                                                  or toPixels( 36 )
	self:setPos(
		parent:getWidth()  - self:getWidth() - margin,
		parent:getHeight() - self:getHeight()
	)
	gui.panel.invalidateLayout( self )
end
