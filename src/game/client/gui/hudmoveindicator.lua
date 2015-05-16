--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Move Indicator HUD
--
--============================================================================--

class "hudmoveindicator" ( gui.panel )

function hudmoveindicator:hudmoveindicator( parent )
	gui.panel.panel( self, parent, "HUD Move Indicator" )

	self.width  = graphics.getViewportWidth()
	self.height = graphics.getViewportHeight()
end

function hudmoveindicator:draw()
end

function hudmoveindicator:invalidateLayout()
	self:setWidth( graphics.getViewportWidth() )
	self:setHeight( graphics.getViewportHeight() )

	gui.panel.invalidateLayout( self )
end

function hudmoveindicator:mousepressed( x, y, button )
	if ( not self:isVisible() ) then
		return
	end

	if ( self.mouseover and button == "r" ) then
		local player   = localplayer
		local position = vector( camera.screenToWorld( x, y ) )
		player:moveTo( position )
	end
end

function hudmoveindicator:update( dt )
	self:invalidate()
end

gui.register( hudmoveindicator, "hudmoveindicator" )
