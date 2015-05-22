--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Region Title HUD
--
--============================================================================--

class "hudnametags" ( gui.panel )

function hudnametags:hudnametags( parent, name )
	gui.panel.panel( self, parent, name )
	self.width  = graphics.getViewportWidth()
	self.height = graphics.getViewportHeight()
	self:setPos( 0, 0 )

	local nametagFont = "fonts/Mark Simonson - Proxima Nova Regular.otf"
	self.nametagFont  = graphics.newFont( nametagFont, 16 )
end

function hudnametags:draw()
	local players  = player.getAll()
	for _, player in pairs( players ) do
		x, y = camera.worldToScreen( player:getPosition().x, player:getPosition().y )
		local font = graphics.setFont( self.nametagFont )
		local nametag = graphics.print( player:getName() or "Unnamed", x, y )
	end
end

function hudnametags:invalidateLayout()
	self:setSize( graphics.getViewportWidth(), graphics.getViewportHeight() )

	gui.panel.invalidateLayout( self )
end

function hudnametags:update( dt )
	if ( self:isVisible() and self:getOpacity() ~= 0 ) then
		self:invalidate()
	end
end

gui.register( hudnametags, "hudnametags" )
