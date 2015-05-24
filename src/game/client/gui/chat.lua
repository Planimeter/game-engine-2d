--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: chat class
--
--============================================================================--

require( "game.client.gui.chatbox" )

class "chat" ( gui.frame )

function onChatReceived( payload )

	local entIndex = payload:get( "entIndex" )
	local message = payload:get( "message" )

	--require( "engine.shared.entities.entity" )

	local ply = entity.getByEntIndex( entIndex )

	sendChat( ply:getName() .. ": " .. message )
end

payload.setHandler( onChatReceived, "chat" )

function sendChat( ... )
	local args = { ... }
	for i = 1, select( "#", ... ) do
		args[ i ] = tostring( args[ i ] )
	end

	if( _CLIENT ) then
		_G.g_Chat.output:insertText( table.concat( args, "\t" ) .. "\n" )
		_G.g_Chat.input:setText( "" )
		--input = string.trim( input )
	end
end

function chat:chat()
	local name = "chat"
	gui.frame.frame( self, nil, name, " " )
	self.width	   = 430
	self.height	   = 280
	self.minHeight = 50

	self.output = gui.chatbox( self, name .. " Output Text Box", "" )
	self.input	= gui.textbox( self, name .. " Input Text Box",	 "" )
	self.input.onEnter = function( textbox, text )
		if( text == "" ) then
		else 
			concommand.run("say " .. text)
		end
	end

	self:invalidateLayout()
	self:doModal()
end

function chat:activate()
	self:invalidate()
	gui.frame.activate( self )
end

function chat:drawBackground()
	--gui.frame.drawBackground( self )
end

function chat:drawForeground()
	--gui.frame.drawForeground( self )
end

function chat:invalidateLayout()
	if ( not self:isResizing() ) then
		local parent = self:getParent()
		local scale	 = parent:getHeight() / 1080
		local margin = 16 * scale

		self:setPos( parent:getWidth() - self:getWidth() - margin, margin )
	end

	self.output:setPos( 16, 16 )
	self.output:setHeight(200)

	self.input:setHeight(30)
	self.input:setPos( 16, self:getHeight() - self.input:getHeight() - 10 )
	self.input:setWidth( self:getWidth() - 2 * 16 )
	gui.frame.invalidateLayout( self )
end

gui.register( chat, "chat" )

_G.g_Chat = gui.chat()

concommand( "chat", "Toggles the chat.", function()
	local visible = _G.g_Chat:isVisible()
	if( not visible ) then
		_G.g_Chat:activate()
		_G.g_Chat:setPos(10, 10)
		--print("Chat opening!")
	else
		_G.g_Chat:close()
		--print("Chat closing!")
	end
end)
