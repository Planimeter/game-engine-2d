--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Game Menu HUD
--
--============================================================================--

class "hudgamemenu" ( gui.hudframe )

function hudgamemenu:hudgamemenu( parent )
	local name = "HUD Game Menu"
	gui.hudframe.hudframe( self, parent, name, name )
	self.width  = point( 384 ) -- - point( 31 )
	self.height = point( 480 )

	require( "game.client.gui.hudgamemenu.navigation" )
	require( "game.client.gui.hudgamemenu.navigationbutton" )
	self.navigation      = gui.hudgamemenunavigation( self )
	local margin         = point( 36 )
	local titleBarHeight = point( 86 )
	self.navigation:setPos( margin, titleBarHeight )
	self.navigation:setWidth( self:getWidth() - 2 * margin )
	self.navigation:setHeight( point( 31 ) )

	require( "game.client.gui.hudgamemenu.inventory" )
	self.inventory = gui.hudgamemenuinventory( self )
	self.inventory:moveToBack()

	require( "game.client.gui.hudgamemenu.stats" )
	self.stats = gui.hudgamemenustats( self )
	self.stats:moveToBack()
	self.stats:setVisible( false )

	self:invalidateLayout()
end

function hudgamemenu:getTitle()
	if ( not self.navigation ) then
		return "Game Menu"
	end

	local item = self.navigation:getSelectedItem()
	return item:getText()
end

function hudgamemenu:invalidateLayout()
	local margin = point( 18 )
	local x = graphics.getViewportWidth()  - self:getWidth()  - margin
	local y = graphics.getViewportHeight() - self:getHeight() - margin
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
