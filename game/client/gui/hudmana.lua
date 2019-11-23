--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Mana HUD
--
--==========================================================================--

class "gui.hudmana" ( "gui.box" )

local hudmana = gui.hudmana

function hudmana:hudmana( parent )
	local name = "HUD Mana"
	gui.box.box( self, parent, name )
	self:setDisplay( "block" )
	self:setPosition( "absolute" )

	self.text = gui.text( self, "" )
	self.text:setDisplay( "block" )
	self.text:setColor( self:getScheme( "hudmoveindicator.textColor" ) )
	self.text:setFont( self:getScheme( "entityFont" ) )

	local label = gui.text( self, "Mana" )
	label:setColor( self:getScheme( "hudmoveindicator.smallTextColor" ) )

	self:invalidateLayout()
end

function hudmana:draw()
	self:drawMana()

	gui.box.draw( self )
end

function hudmana:drawMana()
	local mana = localplayer:getNetworkVar( "mana" )
	self.text:set( mana )
end

function hudmana:invalidateLayout()
	local margin = gui.scale( 96 )
	local graphicsHeight = love.graphics.getHeight()
	local height = self:getHeight()
	self:setPos(
		margin + g_HudHealth:getWidth() + margin / 2,
		graphicsHeight - margin - height
	)

	gui.panel.invalidateLayout( self )
end
