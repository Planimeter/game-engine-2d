--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Main Menu class
--
--============================================================================--

require( "game.client.gui.mainmenu.closebutton" )
require( "game.client.gui.mainmenu.button" )
require( "game.client.gui.mainmenu.axisprofile" )
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

	self.closeButton = gui.mainmenuclosebutton( self )
	local margin     = 96 * ( self.height / 1080 )
	self.closeButton:setPos( self.width - 32 - margin, margin )
	self.closeButton.onClick = function()
		self.closeDialog:activate()
	end

	self.closeDialog = gui.closedialog( self )
	self.closeDialog:moveToCenter()

	self:createButtons()

	if ( _AXIS ) then
		self.signinDialog = gui.signindialog( self )
		self.signinDialog:moveToCenter()
		self.signinDialog:moveToFront()
		self.signinDialog:activate()
	end
end

local MAINMENU_ANIM_TIME = 0.6

function mainmenu:activate()
	if ( not self:isVisible() ) then
		self:setOpacity( 0 )
		self:animate( {
			opacity = 1,
			-- y    = 0
			scale   = 1
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
		opacity = 0,
		-- y    = graphics.getViewportHeight()
		scale   = 0
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

	if ( _DEBUG ) then
		self.joinLocalHost = gui.mainmenubutton( self, "Connect to Localhost" )
		self.joinLocalHost.onClick = function()
			if ( not engine.isConnected() ) then
				engine.connect( "localhost" )
			else
				engine.disconnect()
			end
		end
		table.insert( self.buttons, self.joinLocalHost )
	end

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

function mainmenu:onAxisSignin()
	self:initAxisProfile()
	self:enableUniverseConnections()
end

hook.set( "client", function()
	if ( g_MainMenu ) then
		g_MainMenu:onAxisSignin()
	end
end, "onAxisSignin", "mainmenu.onAxisSignin" )

hook.set( "client", function()
	g_MainMenu.joinLeaveUniverse:setText( "Leave Universe" )
	g_MainMenu.joinLeaveUniverse:setDisabled( false )
end, "onConnect", "updateJoinLeaveUniverseButton" )

hook.set( "client", function()
	g_MainMenu.joinLeaveUniverse:setText( "Join Universe" )

	if ( not _AXIS ) then
		g_MainMenu.joinLeaveUniverse:setDisabled( true )
	end
end, "onDisconnect", "updateJoinLeaveUniverseButton" )

function mainmenu:enableUniverseConnections()
	if ( self.joinLeaveUniverse ) then
		self.joinLeaveUniverse:setDisabled( false )
	end
end

if ( _AXIS ) then
	function mainmenu:initAxisProfile()
		self.axisProfile = gui.axisprofile( self )
		local height     = graphics.getViewportHeight()
		local margin     = 96 * ( height / 1080 )
		local y          = height - self.axisProfile:getHeight() - margin
		self.axisProfile:setPos( margin, y )
		self.axisProfile:activate()
	end
end

function mainmenu:invalidateLayout()
	self:setSize( graphics.getViewportWidth(), graphics.getViewportHeight() )

	local scale  = self:getHeight() / 1080
	local margin = 96 * scale
	local y      = margin
	self.closeButton:setPos( self:getWidth() - 32 - margin, y )

	self.closeDialog:moveToCenter()

	if ( _AXIS ) then
		self.signinDialog:moveToCenter()
	end

	if ( self.testFrame ) then
		self.testFrame:moveToCenter()
	end

	self:invalidateButtons()

	if ( _AXIS ) then
		if ( self.axisProfile ) then
			local height = graphics.getViewportHeight()
			y = height - self.axisProfile:getHeight() - margin
			self.axisProfile:setPos( margin, y )
		end
	end

	gui.panel.invalidateLayout( self )
end

function mainmenu:invalidateButtons()
	local logo      = self.logo
	local height    = self:getHeight()
	local scale     = height / 1080
	local marginPhi = height - height / math.phi
	local marginX   = math.round( 96 * scale )
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
	if ( not self:isVisible() ) then
		return
	end

	self:drawLogo()

	gui.panel.draw( self )
end

function mainmenu:drawLogo()
	local logo      = self.logo
	local height    = self:getHeight()
	local scale     = height / 1080
	local marginX   = math.round( 96 * scale )
	local marginPhi = math.round( height - height / math.phi )

	if ( height <= 720 ) then
		logo  = self.logoSmall
		scale = height / 720
	end

	graphics.setColor( color.white )
	graphics.draw( logo:getDrawable(), marginX, marginPhi, 0, scale, scale )
end

function mainmenu:keypressed( key, isrepeat )
	if ( not self:isVisible() or self.closing ) then
		return
	end

	if ( key == "tab" and self.focus ) then
		gui.frame.moveFocus( self )
	end

	return gui.panel.keypressed( self, key, isrepeat )
end

function mainmenu:mousepressed( x, y, button )
	if ( not self:isVisible() or self.closing ) then
		return
	end

	gui.panel.mousepressed( self, x, y, button )
end

function mainmenu:mousereleased( x, y, button )
	if ( not self:isVisible() or self.closing ) then
		return
	end

	gui.panel.mousereleased( self, x, y, button )
end

function mainmenu:remove()
	gui.panel.remove( self )
	self.logo = nil
end

gui.register( mainmenu, "mainmenu" )
