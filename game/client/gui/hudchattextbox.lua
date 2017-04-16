--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Chat Textbox HUD
--
--============================================================================--

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
	local property = "textbox.outlineColor"
	local width    = self:getWidth()
	local height   = self:getHeight()
	local color    = color( self:getScheme( property ) )
	color[ 4 ]     = color[ 4 ] * self.borderOpacity
	love.graphics.setColor( color )
	love.graphics.setLineWidth( 1 )
	love.graphics.rectangle( "line", 0, 0, width, height )
end

function hudchattextbox:getHideTime()
	return self.hideTime
end

function hudchattextbox:getHudChat()
	return self.hudchat
end

function hudchattextbox:invalidateLayout()
	local parent = self:getHudChat()
	self:setWidth( parent:getWidth() - 2 * point( 36 ) )
	self:setHeight( parent:getHeight() - point( 46 + 9 ) - 2 * point( 36 ) )

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
