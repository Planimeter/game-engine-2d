--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Debug Overlay Panel class
--
--============================================================================--

class "debugoverlaypanel" ( gui.panel )

function debugoverlaypanel:debugoverlaypanel( parent )
	gui.panel.panel( self, parent, "Debug Overlay" )
	self.width  = graphics.getViewportWidth()
	self.height = graphics.getViewportHeight()
	self:setUseFullscreenFramebuffer( true )

	self.overlays = {}
end

function debugoverlaypanel:preDrawWorld()
	for _, overlay in ipairs( self.overlays ) do
		if ( overlay.type == "rectangle" ) then
			camera.drawToWorld( overlay.x, overlay.y, function()
				graphics.setColor( overlay.color )
				graphics.setLineWidth( 1 )
				graphics.rectangle( "line", 0, 0, overlay.width, overlay.height )
			end )
		end
	end

	gui.panel.preDrawWorld( self )
end

function debugoverlaypanel:invalidateLayout()
	self:setSize( graphics.getViewportWidth(), graphics.getViewportHeight() )

	gui.panel.invalidateLayout( self )
end

function debugoverlaypanel:rectangle( x, y, width, height, c, duration )
	local overlay = {
		type     = "rectangle",
		x        = x,
		y        = y,
		width    = width,
		height   = height,
		color    = c,
		duration = duration
	}
	table.insert( self.overlays, overlay )
end

function debugoverlaypanel:update( dt )
	for _, overlay in ipairs( self.overlays ) do
		overlay.duration = overlay.duration - dt
		self:invalidate()
	end

	for i = #self.overlays, 1, -1 do
		if ( self.overlays[ i ].duration <= 0 ) then
			table.remove( self.overlays, i )
			self:invalidate()
		end
	end
end

gui.register( debugoverlaypanel, "debugoverlaypanel" )
