--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Move Indicator HUD
--
--============================================================================--

class "hudmoveindicator" ( gui.panel )

function hudmoveindicator:hudmoveindicator( parent, name )
	gui.panel.panel( self, parent, name )

	self.width  = graphics.getViewportWidth()
	self.height = graphics.getViewportHeight()
end

function hudmoveindicator:draw()
	-- local x, y = input.getMousePosition()
	-- graphics.rectangle( "line", x - 16, y - 16, 32, 32 )
end

function hudmoveindicator:invalidateLayout()
	self:setWidth( graphics.getViewportWidth() )
	self:setHeight( graphics.getViewportHeight() )

	gui.panel.invalidateLayout( self )
end

function hudmoveindicator:update( dt )
	self:invalidate()
end

gui.register( hudmoveindicator, "hudmoveindicator" )
