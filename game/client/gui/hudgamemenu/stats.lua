--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Game Menu Stats class
--
--==========================================================================--

class "gui.hudgamemenustats" ( "gui.box" )

local hudgamemenustats = gui.hudgamemenustats

function hudgamemenustats:hudgamemenustats( parent )
	gui.box.box( self, parent, "Stats" )
	self:setDimensions( parent:getDimensions() )

	local panel = gui.scrollablepanel( self, "Stats Scrollable Panel" )
	panel:setPosition( "absolute" )
	panel:setDimensions( self:getWidth(), self:getHeight() - 135 )
	panel:setInnerHeight( 738 )
	panel:setY( 86 + 31 + 18 )
	panel = panel:getInnerPanel()

	-- Soul
	local name       = "Soul"
	local label      = gui.label( panel, name, name )
	local margin     = 36
	local x          = margin
	local y          = 0
	local fontBold   = self:getScheme( "fontBold" )
	label:setPos( x, y )
	label:setFont( fontBold )

	require( "game.client.gui.hudgamemenu.stat" )
	name             = "Health"
	local stat       = gui.hudgamemenustat( panel, name, "health" )
	local statWidth  = self:getWidth() - 2 * margin
	stat:setWidth( statWidth )
	local lineHeight = fontBold:getHeight()
	y                = y + lineHeight + 17
	stat:setPos( x, y )

	name             = "Prayer"
	local stat       = gui.hudgamemenustat( panel, name, "prayer" )
	stat:setWidth( statWidth )
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
	stat:setWidth( statWidth )
	y                = y + lineHeight + 17
	stat:setPos( x, y )

	name             = "Defense"
	stat             = gui.hudgamemenustat( panel, name, "defense" )
	stat:setWidth( statWidth )
	y                = y + stat:getHeight() + 20
	stat:setPos( x, y )

	name             = "Range"
	stat             = gui.hudgamemenustat( panel, name, "range" )
	stat:setWidth( statWidth )
	y                = y + stat:getHeight() + 20
	stat:setPos( x, y )

	name             = "Magic"
	stat             = gui.hudgamemenustat( panel, name, "magic" )
	stat:setWidth( statWidth )
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
	stat:setWidth( statWidth )
	y                = y + lineHeight + 17
	stat:setPos( x, y )

	name             = "Cooking"
	stat             = gui.hudgamemenustat( panel, name, "cooking" )
	stat:setWidth( statWidth )
	y                = y + stat:getHeight() + 20
	stat:setPos( x, y )

	name             = "Mining"
	stat             = gui.hudgamemenustat( panel, name, "mining" )
	stat:setWidth( statWidth )
	y                = y + stat:getHeight() + 20
	stat:setPos( x, y )

	name             = "Smithing"
	stat             = gui.hudgamemenustat( panel, name, "smithing" )
	stat:setWidth( statWidth )
	y                = y + stat:getHeight() + 20
	stat:setPos( x, y )
end
