--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Main Menu class
--
--============================================================================--

require( "game.client.gui.mainmenu.closebutton" )
require( "game.client.gui.mainmenu.button" )

local color  = color
local engine = engine
local gui    = gui
local hook   = hook
local ipairs = ipairs
local love   = love
local math   = math
local point  = point
local table  = table
local unpack = unpack

class "gui.mainmenu" ( "gui.panel" )

function _M:mainmenu()
	gui.panel.panel( self, g_RootPanel, "Main Menu" )
	self.width       = love.graphics.getWidth()
	self.height      = love.graphics.getHeight()
	self:setScheme( "Default" )
	self:setUseFullscreenFramebuffer( true )

	self.logo        = self:getScheme( "mainmenu.logo" )
	self.logoSmall   = self:getScheme( "mainmenu.logoSmall" )
	self.logo:setFilter( "linear", "linear" )
	self.logoSmall:setFilter( "linear", "linear" )

	self.closeButton = gui.mainmenu.closebutton( self )
	local margin     = gui.scale( 96 )
	self.closeButton:setPos( self.width - point( 32 ) - margin, margin )
	self.closeButton.onClick = function()
		self.closeDialog:activate()
	end

	self.closeDialog = gui.closedialog( self )
	self.closeDialog:moveToCenter()

	self:createButtons()
end

local MAINMENU_ANIM_TIME = 0.2

function _M:activate()
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

function _M:close()
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

function _M:createButtons()
	self.buttons = {}

	self.joinLeaveServer = gui.mainmenu.button( self, "Join Server" )
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

	local blankButton = gui.mainmenu.button( self )
	table.insert( self.buttons, blankButton )

	local options = gui.mainmenu.button( self, "Options" )
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
	g_MainMenu.joinLeaveServer:setText( "Leave Server" )
	g_MainMenu.joinLeaveServer:setDisabled( false )
end, "onConnect", "updateJoinLeaveServerButton" )

hook.set( "client", function()
	g_MainMenu.joinLeaveServer:setText( "Join Server" )
	g_MainMenu.joinLeaveServer:setDisabled( true )
end, "onDisconnect", "updateJoinLeaveServerButton" )

function _M:enableServerConnections()
	if ( self.joinLeaveServer ) then
		self.joinLeaveServer:setDisabled( false )
	end
end

function _M:invalidateLayout()
	self:setSize( love.graphics.getWidth(), love.graphics.getHeight() )

	local margin = gui.scale( 96 )
	local y      = margin
	self.closeButton:setPos( self:getWidth() - point( 32 ) - margin, y )

	self.closeDialog:moveToCenter()

	if ( self.testFrame ) then
		self.testFrame:moveToCenter()
	end

	self:invalidateButtons()

	gui.panel.invalidateLayout( self )
end

function _M:invalidateButtons()
	local logo      = self.logo
	local height    = self:getHeight()
	local marginPhi = height - height / math.phi
	local marginX   = math.round( gui.scale( 96 ) )
	local marginY   = math.round( marginX * ( 2 / 3 ) )

	if ( height <= point( 720 ) ) then
		logo = self.logoSmall
	end

	local y = marginPhi + logo:getHeight() + marginY
	for i, button in ipairs( self.buttons ) do
		i = i - 1
		button:setPos( marginX, y + i * button:getHeight() + i * point( 4.5 ) )
	end
end

function _M:draw()
	if ( engine.client.isInGame() ) then
		self:drawBlur()
		self:drawBackground( "mainmenu.backgroundColor" )
	end

	self:drawLogo()

	gui.panel.draw( self )
end

function _M:drawBlur()
	if ( gui.blurFramebuffer ) then
		gui.blurFramebuffer:draw()
	end
end

function _M:drawLogo()
	local logo      = self.logo
	local height    = self:getHeight()
	local scale     = height / point( 1080 )
	local marginX   = math.round( gui.scale( 96 ) )
	local marginPhi = math.round( height - height / math.phi )

	if ( height <= point( 720 ) ) then
		logo  = self.logoSmall
		scale = height / point( 720 )
	end

	love.graphics.setColor( unpack( color.white ) )
	love.graphics.draw( logo, marginX, marginPhi, 0, scale, scale )
end

function _M:keypressed( key, scancode, isrepeat )
	if ( self.closing ) then
		return
	end

	if ( key == "tab" and self.focus ) then
		gui.frame.moveFocus( self )
	end

	return gui.panel.keypressed( self, key, scancode, isrepeat )
end

function _M:mousepressed( x, y, button, istouch )
	if ( self.closing ) then
		return
	end

	return gui.panel.mousepressed( self, x, y, button, istouch )
end

function _M:mousereleased( x, y, button, istouch )
	if ( self.closing ) then
		return
	end

	gui.panel.mousereleased( self, x, y, button, istouch )
end

function _M:remove()
	gui.panel.remove( self )
	self.logo = nil
end

function _M:update( dt )
	if ( gui.blurFramebuffer and self:isVisible() ) then
		self:invalidate()
	end

	gui.panel.update( self, dt )
end

function _M:quit()
	self:activate()
	self.closeDialog:activate()

	return true
end
