--=========== Copyright © 2017, Planimeter, All rights reserved. ===========--
--
-- Purpose: Test line drawing
--
--==========================================================================--

local name  = "Line Drawing Test"
local frame = gui.frame( nil, name, name )

function frame:draw()
	gui.frame.draw( self )

	love.graphics.setColor( color.red )
	local lineWidth = point( 2 )
	love.graphics.setLineWidth( lineWidth )

	-- Horizontal Line
	-- love.graphics.line(
	-- 	lineWidth / 2,   lineWidth / 2, -- Top-left
	-- 	self:getWidth(), lineWidth / 2  -- Top-right
	-- )

	-- Vertical Line
	-- love.graphics.line(
	-- 	self:getWidth() - lineWidth / 2, 0                -- Top-right
	-- 	self:getWidth() - lineWidth / 2, self:getHeight() -- Bottom-right
	-- )

	-- Three-point line
	love.graphics.line(
		lineWidth / 2,                   lineWidth / 2,   -- Top-left
		self:getWidth() - lineWidth / 2, lineWidth / 2,   -- Top-right
		self:getWidth() - lineWidth / 2, self:getHeight() -- Bottom-right
	)
end

frame:setRemoveOnClose( true )
frame:moveToCenter()
frame:activate()
