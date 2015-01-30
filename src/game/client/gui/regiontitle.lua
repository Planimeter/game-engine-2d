--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Region Title class
--
--============================================================================--

class "regiontitle" ( gui.panel )

function regiontitle:regiontitle( parent, name )
	gui.panel.panel( self, parent, name )
	self.width  = graphics.getViewportWidth()
	self.height = 72
	self:setPos( 0, graphics.getViewportHeight() / 2 - self.height / 2 )

	self.titleFont  = graphics.newFont( "fonts/Mark Simonson - Proxima Nova Bold.otf", 18 )
	self.regionFont = graphics.newFont( "fonts/Old English LET.TTF", 48 )

	-- IMPLEMENT ME: localplayer:getRegion()
	local region = region.getAll()[ 1 ]
	local title  = region:getProperties()[ "regiontitle" ]
	self:setTitle( title )
	self:setRegionName( region:getName() )
end

function regiontitle:activate()
end

function regiontitle:draw()
	graphics.setFont( self.titleFont )
	graphics.printf( string.upper( self:getTitle() ),
	                 0,
	                 0,
	                 graphics.getViewportWidth(),
	                 "center" )

	graphics.setFont( self.regionFont )
	local y = self:getHeight() - self.regionFont:getHeight() + 10
	graphics.printf( string.capitalize( self:getRegionName() ),
	                 0,
					 y,
	                 graphics.getViewportWidth(),
	                 "center" )

	self:drawLines()
end

function regiontitle:drawLines()
	local titleWidth  = self.titleFont:getWidth( string.upper( self:getTitle() ) )
	local regionWidth = self.regionFont:getWidth( string.capitalize( self:getRegionName() ) )
	local padding     = 14
	local x1          = self:getWidth() / 2 - titleWidth / 2
	local y           = self:getHeight() - padding
	local width       = ( titleWidth - regionWidth ) / 2 - padding
	local x2          = x1 + width + 2 * padding + regionWidth
	graphics.rectangle( "fill", x1, y, width, 2 )
	graphics.rectangle( "fill", x2, y, width, 2 )
end

function regiontitle:getRegionName()
	return self.regionName
end

function regiontitle:getTitle()
	return self.title
end

function regiontitle:invalidateLayout()
	self:setWidth( graphics.getViewportWidth() )
	self:setPos( 0, graphics.getViewportHeight() - 72 )

	gui.panel.invalidateLayout( self )
end

function regiontitle:setTitle( title )
	self.title = title
end

function regiontitle:setRegionName( regionName )
	self.regionName = regionName
end

gui.register( regiontitle, "regiontitle" )
