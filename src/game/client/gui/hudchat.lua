--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Chat HUD
--
--============================================================================--

class "hudchat" ( gui.frame )

function hudchat:hudchat( parent )
	local name = "Chat"
	gui.frame.frame( self, parent, "Chat" )
	self.width  = gui.scale( 720 )
	self.height = gui.scale( 404 )

	self.output = gui.hudchattextbox( self, name .. " Output Text Box", "" )
	self.input	= gui.textbox( self, name .. " Input Text Box",	 "" )
	self.input.onEnter = function( textbox, text )
		if ( string.trim( text ) == "" ) then
			return
		end

		concommand.run( "say " .. text )
		self.input:setText( "" )
	end

	self:invalidateLayout()
	self:doModal()
end

function hudchat:activate()
	self:invalidate()
	gui.frame.activate( self )
end

function hudchat:draw()
	if ( not self:isVisible() ) then
		-- return
	end

	self:drawBackground()

	gui.panel.draw( self )
end

function hudchat:drawBackground()
	graphics.setColor( self:getScheme( "hudchat.backgroundColor" ) )
	graphics.rectangle( "fill", 0, 0, self:getWidth(), self:getHeight() )
end

function hudchat:invalidateLayout()
	local parent = self:getParent()
	self:setPos( 0, gui.scale( 494 ) )

	self.output:setPos( 36, 36 )
	self.output:setWidth( self:getWidth() - 2 * 36 )
	self.input:setPos( 36, self:getHeight() - self.input:getHeight() - 36 )
	self.input:setWidth( self:getWidth() - 2 * 36 )
	gui.frame.invalidateLayout( self )
end

gui.register( hudchat, "hudchat" )

concommand( "chat", "Toggles the chat.", function()
	local visible = _G.g_Chat:isVisible()
	if ( not visible ) then
		_G.g_Chat:activate()
	else
		_G.g_Chat:close()
	end
end )

function onChatReceived( payload )
	local entIndex = payload:get( "entIndex" )
	local message  = payload:get( "message" )
	require( "engine.client.chat" )
	if ( entIndex > 0 ) then
		local entity = entity.getByEntIndex( entIndex )
		chat.addText( entity:getName() .. ": " .. message )
		if ( not game.call( "shared", "onPlayerChat", entity, message ) ) then
			return
		end
	else
		chat.addText( "SERVER: " .. message )
	end
end

payload.setHandler( onChatReceived, "chat" )

if ( g_Chat ) then
	local visible = g_Chat:isVisible()
	local output  = g_Chat.output:getText()
	g_Chat:remove()
	g_Chat = nil
	g_Chat = gui.hudchat( g_Viewport )
	g_Chat.output:setText( output )
	if ( visible ) then
		g_Chat:activate()
	end
end
