--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Chat Text Box HUD
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

function hudchattextbox:drawBorder()
	local width  = self:getWidth()
	local height = self:getHeight()
	local color  = color( self:getScheme( "textbox.borderColor" ) )
	color[ 4 ]   = color[ 4 ] * self.borderOpacity
	love.graphics.setColor( color )
	local lineWidth = 1
	love.graphics.setLineWidth( lineWidth )
	love.graphics.rectangle(
		"line",
		lineWidth / 2,
		lineWidth / 2,
		width  - lineWidth,
		height - lineWidth
	)
end

accessor( hudchattextbox, "hideTime" )
accessor( hudchattextbox, "hudchat" )

function hudchattextbox:invalidateLayout()
	local parent        = self:getHudchat()
	local margin        = 36
	local textboxHeight = 46
	local padding       = 9
	local width         = parent:getWidth()
	width               = width - 2 * margin
	local height        = parent:getHeight()
	height              = height - textboxHeight - padding - 2 * margin
	self:setWidth( width )
	self:setHeight( height )

	gui.panel.invalidateLayout( self )
end

function hudchattextbox:update( dt )
	local parent   = self:getHudchat()
	local hideTime = self:getHideTime()
	if ( hideTime and
	     hideTime <= love.timer.getTime() and
	     not parent:isVisible() ) then
		self:hide()
	end

	gui.textbox.update( self, dt )
end

function hudchattextbox:updateCursor()
	local hudchat = self:getHudchat()
	if ( not hudchat:isVisible() ) then
		love.mouse.setCursor()
		return
	end

	gui.textbox.updateCursor( self )
end
