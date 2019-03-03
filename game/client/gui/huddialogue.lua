--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: Dialogue HUD
--
--==========================================================================--

class "gui.huddialogue" ( "gui.hudframe" )

local huddialogue = gui.huddialogue

function huddialogue:huddialogue( parent )
	local name = "HUD Dialogue"
	gui.hudframe.hudframe( self, parent, name, "" )
	self.width  = 320 -- - 31
	self.height = 86

	local box = gui.box( self, name .. " Box" )
	box:setWidth( self.width )
	box:setHeight( self.height )
	box:setPadding( 18 )

	local header = gui.text( box, name .. " Header", "h1" )
	header:setDisplay( "block" )
	header:setMarginBottom( 8 )
	header:setFont( self:getScheme( "fontBold" ) )

	local dialogue = gui.text( box, name .. " Dialogue", "p" )
	dialogue:setDisplay( "block" )

	self:invalidateLayout()
	self:activate()
end

function huddialogue:invalidateLayout()
	local x = love.graphics.getWidth() / 2
	x       = x + 3 * game.tileSize
	local y = love.graphics.getHeight() / 2
	y       = y - self:getHeight() / 2
	y       = y - 2 * game.tileSize
	self:setPos( x, y )
	gui.frame.invalidateLayout( self )
end
