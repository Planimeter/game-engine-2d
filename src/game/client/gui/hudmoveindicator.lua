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
	local x, y = camera.screenToWorld( input.getMousePosition() )
	x, y       = region.snapToGrid( x, y )
	camera.drawToWorld( x, y, function()
		if ( not g_Viewport:isVisible() ) then
			return
		end

		local opacity = graphics.getOpacity()
		graphics.setOpacity( g_Viewport:getOpacity() )
			graphics.setColor( color.red )
			graphics.rectangle( "line", 0, 0, 32, 32 )
			graphics.setColor( color.white )
			local font = scheme.getProperty( "Console", "font" )
			graphics.setFont( font )
			graphics.print( "(" .. x / 32 .. ", " .. y / 32 .. ")", 0, 32 )
		graphics.setOpacity( opacity )
	end )
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
		self:visualizePath( localplayer:getPosition(), position )
	end
end

function hudmoveindicator:update( dt )
	self:invalidate()
end

function hudmoveindicator:visualizePath( from, to )
	require( "engine.shared.path" )
	local path = path.getPath( from, to )
	if ( not path ) then
		return
	end

	for i, node in ipairs( path ) do
		debugoverlay.rectangle( node.x, node.y, 32, 32, color.red, 0.6 )
	end
end

gui.register( hudmoveindicator, "hudmoveindicator" )
