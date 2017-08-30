--=========== Copyright © 2017, Planimeter, All rights reserved. ===========--
--
-- Purpose: Debug Overlay Panel class
--
--==========================================================================--

class "gui.debugoverlaypanel" ( "gui.panel" )

local debugoverlaypanel = gui.debugoverlaypanel

function debugoverlaypanel:debugoverlaypanel( parent )
	gui.panel.panel( self, parent, "Debug Overlay" )
	self.width  = love.graphics.getWidth()
	self.height = love.graphics.getHeight()
	self:setUseFullscreenFramebuffer( true )

	self.overlays = {}
end

local function line( overlay )
	return function()
		love.graphics.setColor( overlay.color )
		local lineWidth = 1
		love.graphics.setLineWidth( lineWidth )
		love.graphics.line( overlay.points )
	end
end

local function rectangle( overlay )
	return function()
		love.graphics.setColor( overlay.color )
		local lineWidth = 1
		love.graphics.setLineWidth( lineWidth )
		love.graphics.rectangle(
			"line",
			lineWidth / 2,
			lineWidth / 2,
			overlay.width  - lineWidth,
			overlay.height - lineWidth
		)
	end
end

function debugoverlaypanel:preDrawWorld()
	for _, overlay in ipairs( self.overlays ) do
		if ( overlay.type == "line" ) then
			camera.drawToWorld(
				overlay.worldIndex,
				overlay.x,
				overlay.y,
				line( overlay )
			)
		end

		if ( overlay.type == "rectangle" ) then
			camera.drawToWorld(
				overlay.worldIndex,
				overlay.x,
				overlay.y,
				rectangle( overlay )
			)
		end
	end

	gui.panel.preDrawWorld( self )
end

function debugoverlaypanel:invalidateLayout()
	self:setSize(
		love.graphics.getWidth(),
		love.graphics.getHeight()
	)

	gui.panel.invalidateLayout( self )
end

function debugoverlaypanel:line( worldIndex, x, y, points, c, duration )
	local overlay = {
		type       = "line",
		worldIndex = worldIndex,
		x          = x,
		y          = y,
		points     = points,
		color      = c,
		duration   = duration
	}
	table.insert( self.overlays, overlay )
end

function debugoverlaypanel:rectangle(
	worldIndex,
	x,
	y,
	width,
	height,
	c,
	duration
)
	local overlay = {
		type       = "rectangle",
		worldIndex = worldIndex,
		x          = x,
		y          = y,
		width      = width,
		height     = height,
		color      = c,
		duration   = duration
	}
	table.insert( self.overlays, overlay )
end

function debugoverlaypanel:update( dt )
	local overlays = self.overlays
	for _, overlay in ipairs( overlays ) do
		overlay.duration = overlay.duration - dt
		self:invalidate()
	end

	for i = #overlays, 1, -1 do
		if ( overlays[ i ].duration <= 0 ) then
			table.remove( overlays, i )
			self:invalidate()
		end
	end
end
