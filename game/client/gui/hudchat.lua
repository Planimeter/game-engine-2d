--=========== Copyright © 2017, Planimeter, All rights reserved. ===========--
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
	self.input  = gui.textbox( self, name .. " Input Text Box", "" )
	self.input.onEnter = function( textbox, text )
		if ( string.trim( text ) == "" ) then
			return
		end

		self:close()
		concommand.run( "say " .. text )
		self.input:setText( "" )
	end

	self.initializing = true
	self:invalidateLayout()
	self:setUseFullscreenFramebuffer( true )
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
	self.width  = math.round( gui.scale( 720 ) )
	self.height = math.round( gui.scale( 404 ) )
	self:setPos(
		gui.scale( 96 ) - point( 36 ) - point( 18 ),
		gui.scale( 494 )
	)

	if ( self.output ) then
		if ( self:isVisible() or self.initializing ) then
			self.initializing = false
			self.output:setPos( point( 36 ), point( 36 ) )
		else
			local x, y = self:localToScreen(
				gui.scale( 96 ) - point( 18 ),
				point( 36 ) + gui.scale( 494 )
			)
			self.output:setPos( x, y )
		end
	end

	if ( self.input ) then
		self.input:setPos(
			point( 36 ),
			self:getHeight() - self.input:getHeight() - point( 36 )
		)
		self.input:setWidth( self:getWidth() - 2 * point( 36 ) )
	end

	gui.frame.invalidateLayout( self )
end



concommand( "chat", "Toggles the chat", function()
	local visible = _G.g_Chat:isVisible()
	if ( not visible ) then
		_G.g_Chat:activate()
	else
		_G.g_Chat:close()
		_G.g_Chat.output:hide()
	end
end )

function onChatReceived( payload )
	local entity  = payload:get( "entity" )
	local message = payload:get( "message" )
	require( "engine.client.chat" )
	if ( entity ) then
		if ( not game.call( "client", "onPlayerChat", entity, message ) ) then
			return
		end

		chat.addText( entity:getName() .. ": " .. message )
	else
		chat.addText( "SERVER: " .. message )
	end
end

payload.setHandler( onChatReceived, "chat" )

if ( g_Chat ) then
	local visible = g_Chat:isVisible()
	local output  = g_Chat.output:getText()
	g_Chat.output:remove()
	g_Chat:remove()
	g_Chat = nil
	g_Chat = gui.hudchat( g_Viewport )
	g_Chat.output:setText( output )
	if ( visible ) then
		g_Chat:activate()
	end
end
