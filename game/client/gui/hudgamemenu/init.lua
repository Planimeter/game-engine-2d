--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Game Menu HUD
--
--==========================================================================--

class "gui.hudgamemenu" ( "gui.hudframe" )

local hudgamemenu = gui.hudgamemenu

function hudgamemenu:hudgamemenu( parent )
	local name = "HUD Game Menu"
	gui.hudframe.hudframe( self, parent, name, name )
	self.width  = 320 -- - 31
	self.height = 432

	require( "game.client.gui.hudgamemenu.navigation" )
	require( "game.client.gui.hudgamemenu.navigationbutton" )
	self.navigation = gui.hudgamemenunavigation( self )
	self.navigation:setPos( 36, 86 )
	self.navigation:setWidth( self.width - 2 * 36 )
	self.navigation:setHeight( 31 )

	require( "game.client.gui.hudgamemenu.inventory" )
	self.inventory = gui.hudgamemenuinventory( self )
	self.inventory:moveToBack()
	_G.g_Inventory = self.inventory

	require( "game.client.gui.hudgamemenu.stats" )
	self.stats = gui.hudgamemenustats( self )
	self.stats:moveToBack()
	self.stats:setVisible( false )

	self:invalidateLayout()
end

function hudgamemenu:getTitle()
	if ( self.navigation == nil ) then
		return "Game Menu"
	end

	local item = self.navigation:getSelectedItem()
	return item:getText()
end

function hudgamemenu:invalidateLayout()
	local x = love.graphics.getWidth()  - self:getWidth()  - 18
	local y = love.graphics.getHeight() - self:getHeight() - 18
	self:setPos( x, y )
	gui.frame.invalidateLayout( self )
end

function hudgamemenu:onRemove()
	_G.g_Inventory = nil
	gui.panel.onRemove( self )
end

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

local function onReloadScript()
	local gamemenu = g_GameMenu
	if ( gamemenu == nil ) then
		return
	end

	local visible = gamemenu:isVisible()
	gamemenu:remove()
	gamemenu = gui.hudgamemenu( g_Viewport )
	g_GameMenu = gamemenu
	if ( visible ) then
		gamemenu:activate()
	end
end

onReloadScript()
