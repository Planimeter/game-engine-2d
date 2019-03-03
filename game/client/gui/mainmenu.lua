--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Main Menu class
--
--==========================================================================--

require( "engine.shared.hook" )

class "gui.mainmenu" ( "gui.box" )

local mainmenu = gui.mainmenu

function mainmenu:mainmenu()
	gui.box.box( self, g_RootPanel, "Main Menu" )
	self:setDisplay( "block" )
	self:setPosition( "absolute" )

	self.width       = love.graphics.getWidth()
	self.height      = love.graphics.getHeight()
	self:setUseFullscreenFramebuffer( true )

	self.logo      = self:getScheme( "logo" )
	self.logoSmall = self:getScheme( "logoSmall" )

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
		-- y     = love.graphics.getHeight()
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

	self.joinLeaveServer = gui.mainmenubutton( self, "Join Server" )
	self.joinLeaveServer:setDisabled( true )
	self.joinLeaveServer.onClick = function()
		if ( not engine.client.isConnected() ) then
			if ( _DEBUG ) then
				engine.client.connect( "localhost" )
			end
		else
			engine.client.disconnect()
		end
	end
	table.insert( self.buttons, self.joinLeaveServer )

	table.insert( self.buttons, gui.mainmenubutton( self ) )

	local options = gui.mainmenubutton( self, "Options" )
	options.onClick = function()
		if ( self.optionsMenu == nil ) then
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
	g_MainMenu.joinLeaveServer:setText( "Leave Server" )
	g_MainMenu.joinLeaveServer:setDisabled( false )
end, "onConnect", "updateJoinLeaveServerButton" )

hook.set( "client", function()
	g_MainMenu.joinLeaveServer:setText( "Join Server" )
	g_MainMenu.joinLeaveServer:setDisabled( true )
end, "onDisconnect", "updateJoinLeaveServerButton" )

function mainmenu:enableServerConnections()
	if ( self.joinLeaveServer ) then
		self.joinLeaveServer:setDisabled( false )
	end
end

function mainmenu:invalidateLayout()
	self:setSize( love.graphics.getWidth(), love.graphics.getHeight() )

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
	local marginX   = gui.scale( 96 )
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
	if ( engine.client.isInGame() ) then
		self:drawTranslucency()
		self:drawBackground()
	end

	self:drawLogo()

	gui.panel.draw( self )
end

function mainmenu:drawTranslucency()
	if ( gui._translucencyFramebuffer ) then
		gui._translucencyFramebuffer:draw()
	end
end

function mainmenu:drawLogo()
	local logo      = self.logo
	local height    = self:getHeight()
	local scale     = height / 1080
	local marginX   = gui.scale( 96 )
	local marginPhi = math.round( height - height / math.phi )

	if ( height <= 720 ) then
		logo  = self.logoSmall
		scale = height / 720
	end

	love.graphics.setColor( color.white )
	love.graphics.draw( logo, marginX, marginPhi, 0, scale, scale )
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
	if ( gui._translucencyFramebuffer and self:isVisible() ) then
		self:invalidate()
	end

	gui.panel.update( self, dt )
end

function mainmenu:quit()
	self:activate()
	self.closeDialog:activate()

	return true
end

local function onReloadScript()
	local oldmenu = g_MainMenu
	if ( oldmenu == nil ) then
		return
	end

	local visible = oldmenu:isVisible()

	-- Initialize main menu
	local newmenu = gui.mainmenu()
	_G.g_MainMenu = newmenu

	g_Console:setParent( newmenu )
	oldmenu:remove()

	if ( visible ) then
		newmenu:activate()
	end
end

onReloadScript()
