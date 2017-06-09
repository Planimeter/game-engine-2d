--=========== Copyright © 2017, Planimeter, All rights reserved. ===========--
--
-- Purpose: Chat Textbox HUD
--
--==========================================================================--

class "gui.hudchattextbox" ( "gui.textbox" )

local hudchattextbox = gui.hudchattextbox

function hudchattextbox:hudchattextbox( parent, name )
	gui.textbox.textbox( self, parent, name, "" )
	self.hudchat = parent

	self:setEditable( false )
	self:setMultiline( true )
	self:setScheme( "Chat" )

	self.borderOpacity = 0
	self:setVisible( false )
end

local CHAT_ANIM_TIME = 0.2

function hudchattextbox:activate()
	if ( not self:isVisible() ) then
		self:setOpacity( 0 )
		self:animate( {
			opacity = 1
		}, CHAT_ANIM_TIME, "easeOutQuint" )
	end

	self:setVisible( true )
end

function hudchattextbox:hide()
	if ( self.hiding ) then
		return
	end

	self.hiding = true

	self:animate( {
		opacity = 0,
	}, CHAT_ANIM_TIME, "easeOutQuint", function()
		self:setVisible( false )
		self:setOpacity( 1 )

		self.hiding   = nil
		self.hideTime = nil
	end )
end

function hudchattextbox:drawForeground()
	local width  = self:getWidth()
	local height = self:getHeight()
	local color  = color( self:getScheme( "textbox.outlineColor" ) )
	color[ 4 ]   = color[ 4 ] * self.borderOpacity
	love.graphics.setColor( color )
	local lineWidth = love.window.toPixels( 1 )
	love.graphics.setLineWidth( lineWidth )
	love.graphics.rectangle(
		"line",
		lineWidth / 2,
		lineWidth / 2,
		width  - lineWidth,
		height - lineWidth
	)
end

function hudchattextbox:getHideTime()
	return self.hideTime
end

function hudchattextbox:getHudChat()
	return self.hudchat
end

function hudchattextbox:invalidateLayout()
	local parent = self:getHudChat()
	self:setWidth( parent:getWidth() - 2 * love.window.toPixels( 36 ) )
	self:setHeight( parent:getHeight() - love.window.toPixels( 46 + 9 ) - 2 * love.window.toPixels( 36 ) )

	gui.panel.invalidateLayout( self )
end

function hudchattextbox:setHideTime( duration )
	self.hideTime = duration
end

function hudchattextbox:update( dt )
	local hudchat  = self:getHudChat()
	local hideTime = self:getHideTime()
	if ( hideTime and
	     hideTime <= love.timer.getTime() and
	     not hudchat:isVisible() ) then
		self:hide()
	end

	gui.textbox.update( self, dt )
end
