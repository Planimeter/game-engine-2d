--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Chat HUD
--
--==========================================================================--

class "gui.hudchat" ( "gui.hudframe" )

local hudchat = gui.hudchat

function hudchat:hudchat( parent )
	local name = "HUD Chat"
	gui.hudframe.hudframe( self, parent, name, name )
	self.width  = gui.scale( 720 )
	self.height = gui.scale( 404 )

	self.output = gui.hudchattextbox( self, name .. " Output Text Box", "" )
	self.output:setMaxLength( 127 * 100 )
	self.input  = gui.textbox( self, name .. " Input Text Box", "" )
	self.input:setPlaceholder( "Chat" )
	self.input.onEnter = function( textbox, text )
		if ( string.trim( text ) == "" ) then
			return
		end

		self:close()
		self.output:updateCursor()
		concommand.run( "say " .. text )
		self.input:setText( "" )
	end

	self.initializing = true
	self:invalidateLayout()
	self:setUseFullscreenCanvas( true )
	self:dock()
end

local CHAT_ANIM_TIME = 0.2

function hudchat:activate()
	if ( not self:isVisible() ) then
		self:invalidateLayout()
		self:setOpacity( 0 )
		self:animate( {
			opacity = 1
		}, CHAT_ANIM_TIME, "easeOutQuint", function()
			self.output:setParent( self )
			self:invalidateLayout()
		end )

		self.output:animate( {
			borderOpacity = 1
		}, CHAT_ANIM_TIME, "easeOutQuint" )
		self.output:activate()
	end

	self:moveToFront()
	self.output:moveToFront()

	self:setVisible( true )
	gui.setFocusedPanel( self.input, true )
end

function hudchat:close()
	if ( self.closing ) then
		return
	end

	self.closing = true
	self:dock()

	self:animate( {
		opacity = 0,
	}, CHAT_ANIM_TIME, "easeOutQuint", function()
		self:setVisible( false )
		self:setOpacity( 1 )

		self.closing = nil
	end )

	self.output:animate( {
		borderOpacity = 0,
	}, CHAT_ANIM_TIME, "easeOutQuint" )

	gui.setFocusedPanel( self.input, false )
end

function hudchat:dock()
	local parent = self:getParent()
	local x, y   = self.output:localToScreen()
	self.output:setParent( parent )
	self.output:setPos( x, y )
end

function hudchat:drawTitle()
end

function hudchat:keypressed( key, scancode, isrepeat )
	if ( key == "escape" ) then
		self:close()
		self.output:hide()
		return true
	end

	return gui.frame.keypressed( self, key, scancode, isrepeat )
end

function hudchat:invalidateLayout()
	self.width           = gui.scale( 720 )
	self.height          = gui.scale( 404 )
	local margin         = gui.scale( 96 )
	local padding        = 36
	local textboxPadding = 18
	local x              = margin - padding - textboxPadding
	local y              = gui.scale( 494 )
	self:setPos( x, y )

	if ( self.output ) then
		if ( self:isVisible() or self.initializing ) then
			self.initializing = false
			self.output:setPos( padding, padding )
		else
			local x, y = margin - textboxPadding, y + padding
			x, y       = self:localToScreen( x, y )
			self.output:setPos( x, y )
		end
	end

	if ( self.input ) then
		local x     = padding
		local y     = self:getHeight() - self.input:getHeight() - padding
		local width = self:getWidth() - 2 * padding
		self.input:setPos( x, y )
		self.input:setWidth( width )
	end

	gui.frame.invalidateLayout( self )
end

concommand( "chat", "Toggles the chat", function()
	local visible = g_Chat:isVisible()
	if ( not visible ) then
		g_Chat:activate()
	else
		g_Chat:close()
		g_Chat.output:hide()
	end
end )

local function onChatReceived( payload )
	local entity  = payload:get( "entity" )
	local message = payload:get( "message" )
	require( "engine.client.chat" )
	if ( entity ) then
		local addText = game.call( "client", "onPlayerChat", entity, message )
		if ( addText == false ) then
			return
		end

		chat.addText( entity:getName() .. ": " .. message )
	else
		chat.addText( "SERVER: " .. message )
	end
end

payload.setHandler( onChatReceived, "chat" )

local function onReloadScript()
	local chat = g_Chat
	if ( chat == nil ) then
		return
	end

	local visible = chat:isVisible()
	local output  = chat.output
	local text    = output:getText()
	chat:remove()
	chat   = gui.hudchat( g_Viewport )
	g_Chat = chat
	output = chat.output
	output:setText( text )
	if ( visible ) then
		chat:activate()
	end
end

onReloadScript()
