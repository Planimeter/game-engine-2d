--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Axis Profile class
--
--============================================================================--

class "axisprofile" ( gui.panel )

axisprofile.background = graphics.newImage( "images/gui/gravatar_background.png" )
axisprofile.fragShader = graphics.newShader( "shaders/alphablend.frag" )

function axisprofile:axisprofile( parent )
	gui.panel.panel( self, parent, "Axis Profile" )
	self.height = 44
	self.width  = graphics.getViewportWidth() - 2 * 36

	self:setScheme( "Default" )

	self.throbber = gui.throbber( self, "Throbber" )
	local x = 22 - self.throbber:getWidth()  / 2
	local y = 22 - self.throbber:getHeight() / 2
	self.throbber:setPos( x, y )
	local textColor     = self:getScheme( "mainmenubutton.dark.textColor" )
	local throbberColor = color( textColor.r, textColor.g, textColor.b, 0.27 * 255 )
	self.throbber:setColor( throbberColor )
end

function axisprofile:activate()
	local account  = axis.getCurrentUser()
	local callback = function( b, c, h )
		self.throbber:disable()
		self:onAvatarDownloaded()
	end
	account:downloadAvatar( callback )

	self.throbber:enable()

	local y = self:getY()
	self:setY( y - 9 )
	self:setOpacity( 0 )
	self:animate( {
		opacity = 1,
		y       = y
	} )
end

local axisGreetings = {
	"Aloha,",
	"Hallo,",
	"Hi,",
	"Hello,",
	"Howdy,",
	"Kumusta,",
	"Sup,",
	"Welcome,"
}

local greeting = table.irandom( axisGreetings )

function axisprofile:draw()
	if ( not self:isVisible() ) then
		return
	end

	local fragShader = gui.axisprofile.fragShader
	fragShader:send( "mask", gui.axisprofile.background:getDrawable() )
	graphics.setShader( fragShader )
		self:drawAvatar()
	graphics.setShader()

	local font = self:getScheme( "titleFont" )
	graphics.setFont( font )
	local x = 44 + 9
	local y = 0
	graphics.print( greeting, x, y )
	y = y + font:getHeight()

	font = self:getScheme( "axisUsernameFont" )
	graphics.setFont( font )
	local account = axis.getCurrentUser()
	graphics.print( account:getUsername(), x, y )

	gui.panel.draw( self )
end

function axisprofile:drawAvatar()
	local opacity = graphics.getOpacity()
	graphics.setOpacity( 0.14 )
	graphics.setColor( self:getScheme( "mainmenubutton.dark.textColor" ) )
	graphics.draw( gui.axisprofile.background:getDrawable() )
	graphics.setOpacity( opacity )
	graphics.setColor( self:getScheme( "mainmenubutton.dark.textColor" ) )

	if ( not self.throbber:isEnabled() and not self.avatar ) then
		local font = self:getScheme( "titleFont" )
		graphics.setFont( font )
		local x = 22 - font:getWidth( "?" ) / 2
		local y = 22 - font:getHeight()     / 2
		graphics.setOpacity( 0.27 )
		graphics.setColor( self:getScheme( "mainmenubutton.dark.textColor" ) )
		graphics.print( "?", x, y )
		graphics.setOpacity( opacity )
		graphics.setColor( self:getScheme( "mainmenubutton.dark.textColor" ) )
	end

	if ( self.avatar ) then
		graphics.draw( self.avatar:getDrawable() )
	end
end

function axisprofile:onAvatarDownloaded()
	local account = axis.getCurrentUser()
	self.avatar   = account:getAvatarImage()
end

gui.register( axisprofile, "axisprofile" )

if ( g_MainMenu and g_MainMenu.axisProfile ) then
	g_MainMenu.axisProfile:remove()
	g_MainMenu.axisProfile = nil
	g_MainMenu.axisProfile = gui.axisprofile( g_MainMenu )
	local height = graphics.getViewportHeight()
	local margin = 96 * ( height / 1080 )
	local y      = height - g_MainMenu.axisProfile:getHeight() - margin
	g_MainMenu.axisProfile:setPos( margin, y )
	g_MainMenu.axisProfile:activate()
end
