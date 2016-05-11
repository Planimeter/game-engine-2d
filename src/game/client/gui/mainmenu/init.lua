--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Main Menu class
--
--============================================================================--

require( "game.client.gui.mainmenu.closebutton" )
require( "game.client.gui.mainmenu.button" )
require( "game.client.gui.closedialog" )

class "mainmenu" ( gui.panel )

function mainmenu:mainmenu()
	gui.panel.panel( self, g_RootPanel, "Main Menu" )
	self.width       = graphics.getViewportWidth()
	self.height      = graphics.getViewportHeight()
	self:setScheme( "Default" )
	self:setUseFullscreenFramebuffer( true )

	self.logo        = self:getScheme( "mainmenu.logo" )
	self.logoSmall   = self:getScheme( "mainmenu.logoSmall" )
	self.logo:setFilter( "linear", "linear" )
	self.logoSmall:setFilter( "linear", "linear" )

	self.closeButton = gui.mainmenuclosebutton( self )
	local margin     = gui.scale( 96 )
	self.closeButton:setPos( self.width - 32 - margin, margin )
	self.closeButton.onClick = function()
		self.closeDialog:activate()
	end

	self.closeDialog = gui.closedialog( self )
	self.closeDialog:moveToCenter()

	self:createButtons()
end

local MAINMENU_ANIM_TIME = 0.2

function mainmenu:activate()
	if ( not self:isVisible() ) then
		self:setOpacity( 0 )
		self:animate( {
			opacity  = 1
			-- y     = 0
			-- scale = 1
		}, MAINMENU_ANIM_TIME, "easeOutQuint" )
	end

	self:setVisible( true )

	if ( game and game.client ) then
		game.call( "client", "onMainMenuActivate" )
	else
		hook.call( "client", "onMainMenuActivate" )
	end
end

function mainmenu:close()
	if ( self.closing ) then
		return
	end

	gui.setFocusedPanel( nil, false )

	self.closing = true

	self:animate( {
		opacity  = 0
		-- y     = graphics.getViewportHeight()
		-- scale = 0
	}, MAINMENU_ANIM_TIME, "easeOutQuint", function()
		self:setVisible( false )
		self:setOpacity( 1 )

		self.closing = nil
	end )

	game.call( "client", "onMainMenuClose" )
end

function mainmenu:createButtons()
	self.buttons = {}
-- if ( _DEBUG ) then
-- 	local testFrame = gui.mainmenubutton( self, "Test Frame" )
-- 	testFrame.onClick = function()
-- 		if ( not self.testFrame ) then
-- 			self.testFrame = gui.testframe( self )
-- 			self.testFrame:activate()
-- 			self.testFrame:moveToCenter()
-- 		else
-- 			self.testFrame:activate()
-- 		end
-- 	end
-- 	table.insert( self.buttons, testFrame )

-- 	local blankButton = gui.mainmenubutton( self )
-- 	table.insert( self.buttons, blankButton )
-- end

	self.joinLeaveUniverse = gui.mainmenubutton( self, "Join Universe" )
	self.joinLeaveUniverse:setDisabled( true )
	self.joinLeaveUniverse.onClick = function()
		if ( not engine.isConnected() ) then
			if ( _DEBUG ) then
				engine.connect( "localhost" )
			else
				-- TODO: Update this to use a universe browser.
				engine.connect( "newton.andrewmcwatters.com" )
			end
		else
			engine.disconnect()
		end
	end
	table.insert( self.buttons, self.joinLeaveUniverse )

	local blankButton = gui.mainmenubutton( self )
	table.insert( self.buttons, blankButton )

	local options = gui.mainmenubutton( self, "Options" )
	options.onClick = function()
		if ( not self.optionsMenu ) then
			self.optionsMenu = gui.optionsmenu( self )
			self.optionsMenu:activate()
			self.optionsMenu:moveToCenter()
		else
			self.optionsMenu:activate()
		end
	end
	table.insert( self.buttons, options )

	self:invalidateButtons()
end

hook.set( "client", function()
	g_MainMenu.joinLeaveUniverse:setText( "Leave Universe" )
	g_MainMenu.joinLeaveUniverse:setDisabled( false )
end, "onConnect", "updateJoinLeaveUniverseButton" )

hook.set( "client", function()
	g_MainMenu.joinLeaveUniverse:setText( "Join Universe" )
	g_MainMenu.joinLeaveUniverse:setDisabled( true )
end, "onDisconnect", "updateJoinLeaveUniverseButton" )

function mainmenu:enableUniverseConnections()
	if ( self.joinLeaveUniverse ) then
		self.joinLeaveUniverse:setDisabled( false )
	end
end

function mainmenu:invalidateLayout()
	self:setSize( graphics.getViewportWidth(), graphics.getViewportHeight() )

	local margin = gui.scale( 96 )
	local y      = margin
	self.closeButton:setPos( self:getWidth() - 32 - margin, y )

	self.closeDialog:moveToCenter()

	if ( self.testFrame ) then
		self.testFrame:moveToCenter()
	end

	self:invalidateButtons()

	gui.panel.invalidateLayout( self )
end

function mainmenu:invalidateButtons()
	local logo      = self.logo
	local height    = self:getHeight()
	local marginPhi = height - height / math.phi
	local marginX   = math.round( gui.scale( 96 ) )
	local marginY   = math.round( marginX * ( 2 / 3 ) )

	if ( height <= 720 ) then
		logo = self.logoSmall
	end

	local y = marginPhi + logo:getHeight() + marginY
	for i, button in ipairs( self.buttons ) do
		i = i - 1
		button:setPos( marginX, y + i * button:getHeight() + i * 4.5 )
	end
end

function mainmenu:draw()
	if ( engine.isInGame() ) then
		self:drawBlur()
		self:drawBackground()
	end

	self:drawLogo()

	gui.panel.draw( self )
end

function mainmenu:drawBackground()
	graphics.setColor( self:getScheme( "mainmenu.backgroundColor" ) )
	graphics.rectangle( "fill", 0, 0, self:getWidth(), self:getHeight() )
end

function mainmenu:drawBlur()
	if ( gui.blurFramebuffer ) then
		gui.blurFramebuffer:draw()
	end
end

function mainmenu:drawLogo()
	local logo      = self.logo
	local height    = self:getHeight()
	local scale     = height / 1080
	local marginX   = math.round( gui.scale( 96 ) )
	local marginPhi = math.round( height - height / math.phi )

	if ( height <= 720 ) then
		logo  = self.logoSmall
		scale = height / 720
	end

	graphics.setColor( color.white )
	graphics.draw( logo:getDrawable(), marginX, marginPhi, 0, scale, scale )
end

function mainmenu:keypressed( key, scancode, isrepeat )
	if ( self.closing ) then
		return
	end

	if ( key == "tab" and self.focus ) then
		gui.frame.moveFocus( self )
	end

	return gui.panel.keypressed( self, key, scancode, isrepeat )
end

function mainmenu:mousepressed( x, y, button, istouch )
	if ( self.closing ) then
		return
	end

	return gui.panel.mousepressed( self, x, y, button, istouch )
end

function mainmenu:mousereleased( x, y, button, istouch )
	if ( self.closing ) then
		return
	end

	gui.panel.mousereleased( self, x, y, button, istouch )
end

function mainmenu:remove()
	gui.panel.remove( self )
	self.logo = nil
end

function mainmenu:update( dt )
	if ( gui.blurFramebuffer and self:isVisible() ) then
		self:invalidate()
	end

	gui.panel.update( self, dt )
end

gui.register( mainmenu, "mainmenu" )
