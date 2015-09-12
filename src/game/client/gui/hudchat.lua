--========= Copyright Â© 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Chat HUD
--
--============================================================================--

class "hudchat" ( gui.panel )

function hudchat:hudchat( parent )
	local name = "Chat"
	gui.panel.panel( self, parent, "Chat" )
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

	self:invalidateLayout()
	self:setScheme( "Default" )
	self:setUseFullscreenFramebuffer( true )
	self:dock()
	self:setVisible( false )
end

local CHAT_ANIM_TIME = 0.2

function hudchat:activate()
	if ( not self:isVisible() ) then
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
	-- self.output:hide()

	gui.setFocusedPanel( self.input, false )
end

function hudchat:dock()
	local parent = self:getParent()
	local x, y   = self.output:localToScreen()
	self.output:setParent( parent )
	self.output:setPos( x, y )
end

function hudchat:draw()
	self:drawBlur()
	self:drawBackground()
	gui.panel.draw( self )
	self:drawForeground()
end

function hudchat:drawBackground()
	graphics.setColor( self:getScheme( "hudchat.backgroundColor" ) )
	graphics.rectangle( "fill", 0, 0, self:getWidth(), self:getHeight() )
end

function hudchat:drawBlur()
	graphics.push()
		local x, y = self:localToScreen()
		graphics.translate( -x, -y )
		gui.blurFramebuffer:draw()
	graphics.pop()
end

function hudchat:drawForeground()
	graphics.setColor( self:getScheme( "frame.outlineColor" ) )
	graphics.setLineWidth( 1 )
	graphics.rectangle( "line", 0, 0, self:getWidth(), self:getHeight() )
end

function hudchat:keypressed( key, isrepeat )
	if ( key == "escape" ) then
		self:close()
		self.output:hide()
		return true
	end

	return gui.panel.keypressed( self, key, isrepeat )
end

function hudchat:invalidateLayout()
	self.width  = math.round( gui.scale( 720 ) )
	self.height = math.round( gui.scale( 404 ) )
	self:setPos( 0, gui.scale( 494 ) )

	if ( self:isVisible() ) then
		self.output:setPos( 36, 36 )
	else
		local x, y = self:localToScreen( 36, 36 + gui.scale( 494 ) )
		self.output:setPos( x, y )
	end

	self.input:setPos( 36, self:getHeight() - self.input:getHeight() - 36 )
	self.input:setWidth( self:getWidth() - 2 * 36 )
	gui.panel.invalidateLayout( self )
end

function hudchat:update( dt )
	if ( self:getOpacity() > 0 ) then
		self:invalidate()
	end

	gui.panel.update( self, dt )
end

gui.register( hudchat, "hudchat" )

concommand( "chat", "Toggles the chat.", function()
	local visible = _G.g_Chat:isVisible()
	if ( not visible ) then
		_G.g_Chat:activate()
	else
		_G.g_Chat:close()
		_G.g_Chat.output:hide()
	end
end )

function onChatReceived( payload )
	local entIndex = payload:get( "entIndex" )
	local message  = payload:get( "message" )
	require( "engine.client.chat" )
	if ( entIndex > 0 ) then
		local entity = entity.getByEntIndex( entIndex )
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
