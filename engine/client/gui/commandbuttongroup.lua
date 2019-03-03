--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Command Button Group class
--
--==========================================================================--

class "gui.commandbuttongroup" ( "gui.box" )

local commandbuttongroup = gui.commandbuttongroup

function commandbuttongroup:commandbuttongroup( parent, name )
	gui.box.box( self, parent, name )
	self:setDisplay( "block" )
	self:setPosition( "absolute" )

	self:invalidateLayout()
end

function commandbuttongroup:draw()
	gui.box.draw( self )

	local color  = self:getScheme( "commandbuttongroup.borderColor" )
	local width  = self:getWidth()
	local height = self:getHeight()

	love.graphics.setColor( color )
	love.graphics.setLineStyle( "rough" )
	local lineWidth = 1
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
	local margin   = typeof( parent, "tabbedframe" ) and 24 or 36
	self:setPos(
		parent:getWidth()  - self:getWidth() - margin,
		parent:getHeight() - self:getHeight()
	)
	gui.panel.invalidateLayout( self )
end
