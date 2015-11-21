		--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Game Menu HUD
--
--============================================================================--

require( "game.client.gui.hudgamemenu.navigation" )
require( "game.client.gui.hudgamemenu.navigationbutton" )
require( "game.client.gui.hudgamemenu.inventory" )
require( "game.client.gui.hudgamemenu.prayer" )
require( "game.client.gui.hudgamemenu.spells" )
require( "game.client.gui.hudgamemenu.stats" )
require( "game.client.gui.hudgamemenu.quests" )

class "hudgamemenu" ( gui.panel )

function hudgamemenu:hudgamemenu( parent )
	gui.panel.panel( self, parent, "Game Menu" )
	self.width  = 384 -- - 31
	self.height = 480

	self:invalidateLayout()
	self:setScheme( "Default" )
	self:setVisible( false )

	self.navigation = gui.hudgamemenunavigation( self )
	self.navigation:setPos( 36, 86 )
	self.navigation:setWidth( self.width - 2 * 36 )
	self.navigation:setHeight( 31 )

	self.inventory = gui.hudgamemenuinventory( self )
	self.inventory:moveToBack()

	-- self.prayer = gui.hudgamemenuprayer( self )
	-- self.prayer:moveToBack()
	-- self.prayer:setVisible( false )
	--
	-- self.spells = gui.hudgamemenuspells( self )
	-- self.spells:moveToBack()
	-- self.spells:setVisible( false )
	--
	-- self.stats = gui.hudgamemenustats( self )
	-- self.stats:moveToBack()
	-- self.stats:setVisible( false )
	--
	-- self.quests = gui.hudgamemenuquests( self )
	-- self.quests:moveToBack()
	-- self.quests:setVisible( false )
end

local GAMEMENU_ANIM_TIME = 0.2

function hudgamemenu:activate()
	if ( not self:isVisible() ) then
		self:setOpacity( 0 )
		self:animate( {
			opacity = 1
		}, GAMEMENU_ANIM_TIME, "easeOutQuint" )
	end

	self:moveToFront()
	self:setVisible( true )
end

function hudgamemenu:close()
	if ( self.closing ) then
		return
	end

	self.closing = true

	self:animate( {
		opacity = 0,
	}, GAMEMENU_ANIM_TIME, "easeOutQuint", function()
		self:setVisible( false )
		self:setOpacity( 1 )

		self.closing = nil
	end )
end

function hudgamemenu:draw()
	self:drawBlur()
	self:drawBackground()
	gui.panel.draw( self )
	self:drawTitle()
	self:drawForeground()
end

function hudgamemenu:drawBackground()
	graphics.setColor( self:getScheme( "hudgamemenu.backgroundColor" ) )
	graphics.rectangle( "fill", 0, 0, self:getWidth(), self:getHeight() )
end

function hudgamemenu:drawBlur()
	if ( not gui.blurFramebuffer ) then
		return
	end

	graphics.push()
		local x, y = self:localToScreen()
		graphics.translate( -x, -y )
		gui.blurFramebuffer:draw()
	graphics.pop()
end

function hudgamemenu:drawForeground()
	graphics.setColor( self:getScheme( "frame.outlineColor" ) )
	graphics.setLineWidth( 1 )
	graphics.rectangle( "line", 0, 0, self:getWidth(), self:getHeight() )
end

function hudgamemenu:drawTitle()
	local property = "frame.titleTextColor"
	graphics.setColor( self:getScheme( property ) )
	local font = self:getScheme( "titleFont" )
	graphics.setFont( font )
	local item = self.navigation:getSelectedItem()
	local title = item:getText()
	local x = 36
	local y = x - 4
	graphics.print( string.utf8upper( title ), x, y )
end

function hudgamemenu:invalidateLayout()
	local x = graphics.getViewportWidth() - self:getWidth() - 18
	local y = graphics.getViewportHeight() - self:getHeight() - 18
	self:setPos( x, y )
	gui.panel.invalidateLayout( self )
end

function hudgamemenu:update( dt )
	if ( gui.blurFramebuffer and self:isVisible() ) then
		self:invalidate()
	end

	gui.panel.update( self, dt )
end

gui.register( hudgamemenu, "hudgamemenu" )

concommand( "+gamemenu", "Opens the gamemenu", function()
	local visible = _G.g_GameMenu:isVisible()
	if ( not visible ) then
		_G.g_GameMenu:activate()
	end
end )

concommand( "-gamemenu", "Closes the gamemenu", function()
	local visible = _G.g_GameMenu:isVisible()
	if ( visible ) then
		_G.g_GameMenu:close()
	end
end )

if ( g_GameMenu ) then
	local visible = g_GameMenu:isVisible()
	g_GameMenu:remove()
	g_GameMenu = nil
	g_GameMenu = gui.hudgamemenu( g_Viewport )
	if ( visible ) then
		g_GameMenu:activate()
	end
end
