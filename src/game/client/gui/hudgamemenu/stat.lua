--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Game Menu Stat class
--
--============================================================================--

class "hudgamemenustat" ( gui.panel )

function hudgamemenustat:hudgamemenustat( parent, name, stat )
	gui.panel.panel( self, parent, name )
	self.width        = 312
	self.height       = 42
	self.stat         = stat

	self:setScheme( "Default" )

	local progressbar = gui.progressbar( self, "Stat Progress" )
	progressbar:setY( 23 )
	self.progressbar  = progressbar
end

function hudgamemenustat:draw()
	local property = "label.textColor"
	local font     = self:getScheme( "font" )
	local stat     = self:getStat()
	graphics.setColor( self:getScheme( property ) )
	graphics.setFont( font )
	graphics.print( string.capitalize( stat ), 0, 0 )

	property = "colors.gold"
	font     = self:getScheme( "fontBold" )
	local x  = self:getWidth() - font:getWidth( "Level 1" )
	graphics.setColor( self:getScheme( property ) )
	graphics.setFont( font )
	graphics.print( "Level 1", x, 0 )

	property = "label.textColor"
	font     = self:getScheme( "fontSmall" )
	x        = self:getWidth() - font:getWidth( "0 / 83 XP" )
	graphics.setColor( self:getScheme( property ) )
	graphics.setFont( font )
	graphics.print( "0 / 83 XP", x, 30 )

	gui.panel.draw( self )
end

function hudgamemenustat:getStat()
	return self.stat
end

function hudgamemenustat:setStat( stat )
	self.stat = stat
end

function hudgamemenustat:setWidth( width )
	gui.panel.setWidth( self, width )
	self.progressbar:setWidth( width )
end

gui.register( hudgamemenustat, "hudgamemenustat" )
