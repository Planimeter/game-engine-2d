--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Health HUD
--
--==========================================================================--

class "gui.hudhealth" ( "gui.box" )

local hudhealth = gui.hudhealth

function hudhealth:hudhealth( parent )
	local name = "HUD Health"
	gui.box.box( self, parent, name )
	self:setDisplay( "block" )
	self:setPosition( "absolute" )

	self.text = gui.text( self, "" )
	self.text:setDisplay( "block" )
	self.text:setColor( self:getScheme( "hudmoveindicator.textColor" ) )
	self.text:setFont( self:getScheme( "entityFont" ) )

	local label = gui.text( self, "Health" )
	label:setColor( self:getScheme( "hudmoveindicator.smallTextColor" ) )

	self:invalidateLayout()
end

function hudhealth:draw()
	self:drawHealth()

	gui.box.draw( self )
end

function hudhealth:drawHealth()
	local health = localplayer:getNetworkVar( "health" )
	self.text:set( health )
end

function hudhealth:invalidateLayout()
	local margin = gui.scale( 96 )
	local graphicsHeight = love.graphics.getHeight()
	local height = self:getHeight()
	self:setPos( margin, graphicsHeight - margin - height )

	gui.panel.invalidateLayout( self )
end
