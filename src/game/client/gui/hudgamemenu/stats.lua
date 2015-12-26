--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Game Menu Stats class
--
--============================================================================--

class "hudgamemenustats" ( gui.panel )

function hudgamemenustats:hudgamemenustats( parent )
	gui.panel.panel( self, parent, "Stats" )
	self:setScheme( "Default" )
	self:setSize( parent:getSize() )

	local panel = gui.scrollablepanel( self, "Stats Scrollable Panel" )
	panel:setSize( self:getWidth(), 345 )
	panel:setInnerHeight( 738 )
	panel:setY( 86 + 31 + 18 )
	panel = panel:getInnerPanel()

	-- Soul
	local name       = "Soul"
	local label      = gui.label( panel, name, name )
	local x          = 36
	local y          = 0
	local fontBold   = self:getScheme( "fontBold" )
	label:setPos( x, y )
	label:setFont( fontBold )

	require( "game.client.gui.hudgamemenu.stat" )
	name             = "Health"
	local stat       = gui.hudgamemenustat( panel, name, "health" )
	stat:setWidth( 312 )
	local lineHeight = fontBold:getHeight()
	y                = y + lineHeight + 17
	stat:setPos( x, y )

	name             = "Prayer"
	local stat       = gui.hudgamemenustat( panel, name, "prayer" )
	stat:setWidth( 312 )
	y                = y + stat:getHeight() + 20
	stat:setPos( x, y )

	-- Combat
	name             = "Combat"
	label            = gui.label( panel, name, name )
	y                = y + stat:getHeight() + 20
	label:setPos( x, y )
	label:setFont( fontBold )

	name             = "Attack"
	stat             = gui.hudgamemenustat( panel, name, "attack" )
	stat:setWidth( 312 )
	y                = y + lineHeight + 17
	stat:setPos( x, y )

	name             = "Defense"
	stat             = gui.hudgamemenustat( panel, name, "defense" )
	stat:setWidth( 312 )
	y                = y + stat:getHeight() + 20
	stat:setPos( x, y )

	name             = "Range"
	stat             = gui.hudgamemenustat( panel, name, "range" )
	stat:setWidth( 312 )
	y                = y + stat:getHeight() + 20
	stat:setPos( x, y )

	name             = "Magic"
	stat             = gui.hudgamemenustat( panel, name, "magic" )
	stat:setWidth( 312 )
	y                = y + stat:getHeight() + 20
	stat:setPos( x, y )

	-- Artisan
	name             = "Artisan"
	label            = gui.label( panel, name, name )
	y                = y + stat:getHeight() + 20
	label:setPos( x, y )
	label:setFont( fontBold )

	name             = "Fishing"
	stat             = gui.hudgamemenustat( panel, name, "fishing" )
	stat:setWidth( 312 )
	y                = y + lineHeight + 17
	stat:setPos( x, y )

	name             = "Cooking"
	stat             = gui.hudgamemenustat( panel, name, "cooking" )
	stat:setWidth( 312 )
	y                = y + stat:getHeight() + 20
	stat:setPos( x, y )

	name             = "Mining"
	stat             = gui.hudgamemenustat( panel, name, "mining" )
	stat:setWidth( 312 )
	y                = y + stat:getHeight() + 20
	stat:setPos( x, y )

	name             = "Smithing"
	stat             = gui.hudgamemenustat( panel, name, "smithing" )
	stat:setWidth( 312 )
	y                = y + stat:getHeight() + 20
	stat:setPos( x, y )
end

gui.register( hudgamemenustats, "hudgamemenustats" )
