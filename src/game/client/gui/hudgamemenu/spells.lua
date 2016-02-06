--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Game Menu Spells class
--
--============================================================================--

class "hudgamemenuspells" ( gui.panel )

function hudgamemenuspells:hudgamemenuspells( parent )
	gui.panel.panel( self, parent, "Spells" )
	self:setScheme( "Default" )
	self:setSize( parent:getSize() )

	local panel = gui.scrollablepanel( self, "Spells Scrollable Panel" )
	panel:setSize( self:getWidth(), 345 )
	panel:setY( 86 + 31 + 18 )
	self.innerPanel = panel:getInnerPanel()
end

local function getLastY( self )
	local children = self:getChildren()
	if ( children ) then
		local y = 0
		for _, panel in ipairs( children ) do
			y = y + panel:getHeight()
		end
		return y
	end
	return 0
end

function hudgamemenuspells:addSpell( spell )
	local panel = self:getInnerPanel()
	local name  = spell .. " Spell Item"
	local y     = getLastY( panel )
	local spell = gui.spellitem( panel, name, spell )
	spell:setY( y )
	self:setInnerHeight( getLastY( panel ) )
end

function hudgamemenuspells:removeSpells()
	local panel = self:getInnerPanel()
	panel:removeChildren()
	self:setInnerHeight( getLastY( panel ) )
end

function hudgamemenuspells:getInnerPanel()
	return self.innerPanel
end

function hudgamemenuspells:setInnerHeight( height )
	local innerPanel = self:getInnerPanel()
	innerPanel:setInnerHeight( height )
end

gui.register( hudgamemenuspells, "hudgamemenuspells" )
