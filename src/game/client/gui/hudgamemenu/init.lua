--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Game Menu HUD
--
--============================================================================--

class "hudgamemenu" ( gui.hudframe )

function hudgamemenu:hudgamemenu( parent )
	local name = "Game Menu"
	gui.hudframe.hudframe( self, parent, name, name )
	self.width  = point( 384 ) -- - point( 31 )
	self.height = point( 480 )

	require( "game.client.gui.hudgamemenu.navigation" )
	require( "game.client.gui.hudgamemenu.navigationbutton" )
	self.navigation = gui.hudgamemenunavigation( self )
	self.navigation:setPos( point( 36 ), point( 86 ) )
	self.navigation:setWidth( self.width - 2 * point( 36 ) )
	self.navigation:setHeight( point( 31 ) )

	require( "game.client.gui.hudgamemenu.inventory" )
	self.inventory = gui.hudgamemenuinventory( self )
	self.inventory:moveToBack()

	require( "game.client.gui.hudgamemenu.prayer" )
	self.prayer = gui.hudgamemenuprayer( self )
	self.prayer:moveToBack()
	self.prayer:setVisible( false )

	require( "game.client.gui.hudgamemenu.spells" )
	self.spells = gui.hudgamemenuspells( self )
	self.spells:moveToBack()
	self.spells:setVisible( false )

	require( "game.client.gui.hudgamemenu.stats" )
	self.stats = gui.hudgamemenustats( self )
	self.stats:moveToBack()
	self.stats:setVisible( false )

	require( "game.client.gui.hudgamemenu.quests" )
	self.quests = gui.hudgamemenuquests( self )
	self.quests:moveToBack()
	self.quests:setVisible( false )

	self:invalidateLayout()
end

function hudgamemenu:getTitle()
	local item = self.navigation:getSelectedItem()
	return item:getText()
end

function hudgamemenu:invalidateLayout()
	local x = graphics.getViewportWidth()  - self:getWidth()  - point( 18 )
	local y = graphics.getViewportHeight() - self:getHeight() - point( 18 )
	self:setPos( x, y )
	gui.frame.invalidateLayout( self )
end

gui.register( hudgamemenu, "hudgamemenu" )

concommand( "+gamemenu", "Opens the gamemenu", function()
	local visible = _G.g_GameMenu:isVisible()
	if ( not visible ) then
		_G.g_GameMenu:activate()
	end
end, { "game" } )

concommand( "-gamemenu", "Closes the gamemenu", function()
	local visible = _G.g_GameMenu:isVisible()
	if ( visible ) then
		_G.g_GameMenu:close()
	end
end, { "game" } )

if ( g_GameMenu ) then
	local visible = g_GameMenu:isVisible()
	g_GameMenu:remove()
	g_GameMenu = nil
	g_GameMenu = gui.hudgamemenu( g_Viewport )
	if ( visible ) then
		g_GameMenu:activate()
	end
end
