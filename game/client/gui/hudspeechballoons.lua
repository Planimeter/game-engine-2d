--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: Speech Balloons HUD
--
--==========================================================================--

class "gui.hudspeechballoons" ( "gui.panel" )

local hudspeechballoons = gui.hudspeechballoons

function hudspeechballoons:hudspeechballoons( parent )
	gui.panel.panel( self, parent, "HUD Speech Balloons" )

	self:setScheme( "Default" )
	self:addChatHook()
	self:invalidateLayout()
end

local function addSpeechBalloon( self )
	return function( player, message )
		if ( self.speechBalloons == nil ) then
			self.speechBalloons = {}
		end

		local readingtime = math.max( string.readingtime( message ), 5 )
		self.speechBalloons[ player ] = {
			player  = player,
			message = message,
			expire  = love.timer.getTime() + readingtime
		}
	end
end

function hudspeechballoons:addChatHook()
	local event = "onPlayerChat"
	local name  = "addSpeechBalloon"
	hook.set( "client", addSpeechBalloon( self ), event, name )
end

function hudspeechballoons:removeChatHook()
	local event = "onPlayerChat"
	local name  = "addSpeechBalloon"
	hook.remove( "client", event, name )
end

function hudspeechballoons:draw()
	self:drawBalloons()

	gui.panel.draw( self )
end

function hudspeechballoons:drawBalloons()
	if ( self.speechBalloons == nil ) then
		return
	end

	local font = self:getScheme( "fontBold" )
	love.graphics.setFont( font )
	love.graphics.setColor( self:getScheme( "hudspeechballoons.textColor" ) )

	for player, balloon in pairs( self.speechBalloons ) do
		local x, y   = player:getDrawPosition()
		x, y         = camera.worldToScreen( x, y )
		local sprite = player:getSprite()
		local scale  = camera.getZoom()
		local width  = font:getWidth( balloon.message )
		local height = font:getHeight()
		x            = x + sprite:getWidth() * scale / 2
		x            = x - width / 2
		x            = math.round( x )
		y            = y - font:getHeight()
		y            = y - love.window.toPixels( 9 )
		y            = math.round( y )
		love.graphics.print( balloon.message, x, y )
	end
end

function hudspeechballoons:invalidateLayout()
	self:setWidth( love.graphics.getWidth() )
	self:setHeight( love.graphics.getHeight() )

	gui.panel.invalidateLayout( self )
end

function hudspeechballoons:onRemove()
	self:removeChatHook()
	gui.panel.onRemove( self )
end

function hudspeechballoons:update( dt )
	if ( not self:isVisible() ) then
		return
	end

	self:updateBalloons()
	self:invalidate()
end

function hudspeechballoons:updateBalloons()
	if ( self.speechBalloons == nil ) then
		return
	end

	for player, balloon in pairs( self.speechBalloons ) do
		if ( balloon.expire <= love.timer.getTime() ) then
			self.speechBalloons[ player ] = nil
		end
	end
end
