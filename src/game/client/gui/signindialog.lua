--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Sign In Dialog class
--
--============================================================================--

require( "engine.shared.axis" )

class "signindialog" ( gui.frame )

local margin = 36

local animation = {
	fadeIn = {
		opacity = 1
	},

	fadeOut = {
		opacity = 0
	},

	register = {
		opacity = 1,
		x = margin
	},

	registerReset = {
		opacity = 1,
		x = margin + 65
	},

	slideDownConfirmPasswordTextBox = {
		opacity = 1,
		y = 167 + 46 + 9
	},

	slideUpConfirmPasswordTextBox = {
		opacity = 0,
		y = 167
	},

	slideDownEmailTextBox = {
		opacity = 1,
		y = 167 + 2 * ( 46 + 9 )
	},

	slideUpEmailTextBox = {
		opacity = 0,
		y = 167
	}
}

local function disableTextBoxes( self )
	self.usernameTextBox:setDisabled( true )
	self.passwordTextBox:setDisabled( true )
	self.confirmPasswordTextBox:setDisabled( true )
	self.emailTextBox:setDisabled( true )
end

local function enableTextBoxes( self )
	self.usernameTextBox:setDisabled( false )
	self.passwordTextBox:setDisabled( false )
	self.confirmPasswordTextBox:setDisabled( false )
	self.emailTextBox:setDisabled( false )
end

local _username = ""
local _password = ""

local function signin( self )
	local username = self.usernameTextBox:getText()
	local password = self.passwordTextBox:getPassword()
	if ( username == "" ) then
		self:setLabel( "Please enter your username" )
		return
	elseif ( password == "" ) then
		self:setLabel( "Please enter your password" )
		return
	end

	disableTextBoxes( self )
	self.throbber:enable()

	axis.signin( username, password, function( r, c )
		if ( not self ) then
			return
		end

		self.throbber:disable()
		enableTextBoxes( self )

		if ( c == 200 ) then
			local account = axis.getCurrentUser()
			self:setLabel( "Welcome, " .. account:getUsername() )
			self:close()

			_username = username
			_password = password
			hook.call( "client", "onAxisSignin" )

			return
		elseif ( r == "Incorrect Password" ) then
			self:setLabel( "Incorrect password" )
		elseif ( r == "Account Not Verified" ) then
			self:setLabel( "Account not verified" )
		elseif ( r == "Not Found" ) then
			self:setLabel( "Account not found" )
		elseif ( r == nil ) then
			self:setLabel( "Error connecting to Axis" )
		else
			self:setLabel( tostring( r ) )
		end
	end )
end

local axis_remember_password = convar( "axis_remember_password", "0", nil, nil,
                                       "Remember Axis password" )

local function rememberPassword()
	if ( not axis_remember_password:getBoolean() ) then
		return
	end

	local profile = _username .. "\r\n" ..
	                _password .. "\r\n"
	if ( filesystem.write( ".profile", profile ) ) then
		print( "Saved password." )
	else
		print( "Failed to save password!" )
	end
end

hook.set( "client", rememberPassword, "onAxisSignin", "rememberPassword" )

local function register( self )
	local username          = self.usernameTextBox:getText()
	local password          = self.passwordTextBox:getPassword()        or ""
	local confirmedPassword = self.confirmPasswordTextBox:getPassword() or ""
	local email             = self.emailTextBox:getText()
	if ( password == "" ) then
		self:setLabel( "Please enter a password" )
		return
	elseif ( password ~= confirmedPassword ) then
		self:setLabel( "Your passwords do not match" )
		self.passwordTextBox:setPassword( "" )
		self.confirmPasswordTextBox:setPassword( "" )
		gui.setFocusedPanel( self.passwordTextBox, true )
		return
	elseif ( email == "" ) then
		self:setLabel( "Please provide an email address" )
		return
	end

	disableTextBoxes( self )
	self.throbber:enable()

	axis.createAccount( username, password, email, function( r, c )
		if ( not self ) then
			return
		end

		self.throbber:disable()
		enableTextBoxes( self )

		if ( c == 200 ) then
			self:setSignIn( true )
			self:setLabel( "Welcome to Axis" )
		elseif ( r == "Invalid Email" ) then
			self:setLabel( "Invalid email" )
		elseif ( r == "Username Taken" ) then
			self:setLabel( "Username taken" )
		else
			self:setLabel( tostring( r ) )
		end
	end )
end

local function signInOrRegister( self )
	self = self:getParent()

	if ( not self.register ) then
		signin( self )
	else
		register( self )
	end
end

local function readPassword( self )
	if ( not filesystem.exists( ".profile" ) ) then
		return
	end

	local profile  = string.split( filesystem.read( ".profile" ) , "\r\n" )
	local username = profile[ 1 ]
	local password = profile[ 2 ]
	self.usernameTextBox:setText( username )
	self.passwordTextBox:setText( password )

	-- Andrew; Force dialog to update.
	self.usernameTextBox:onLostFocus()
end

function signindialog:signindialog( parent, name )
	gui.frame.frame( self, parent, "Sign In Dialog", "" )
	self.width = 288
	self.height = 282
	self.register = false

	self:doModal()

	local image = gui.image( self, "Axis Logo", "images/gui/logo_axis.png" )
	image:setPos( margin, margin )
	image:setSize( 37, 11 )

	self.throbber = gui.throbber( self, "Throbber" )
	local x = self:getWidth() - self.throbber:getWidth() - margin
	local y = margin - ( self.throbber:getHeight() - image:getHeight() ) / 2
	self.throbber:setPos( x, y )
	self.throbber:setColor( self:getScheme( "label.textColor" ) )

	self.label = gui.label( self, "Label", "" )
	y = 86
	self.label:setPos( margin, y )

	self.signinLabel = gui.label( self, "Sign in Label", "Sign in" )
	self.signinLabel:setPos( margin, y )
	self.signinLabel:setFont( self:getScheme( "fontBold" ) )

	self.orLabel = gui.label( self, "or Label", "or" )
	self.orLabel:setPos( margin + 48, y )
	self.orLabel:setFont( self:getScheme( "fontBold" ) )

	self.registerLabel = gui.label( self, "Register Label", "Register" )
	self.registerLabel:setPos( margin + 65, y )
	self.registerLabel:setFont( self:getScheme( "fontBold" ) )

	y = y + self.signinLabel:getHeight() + 9
	self.usernameTextBox = gui.textbox( self, "Username Text Box", "Username" )
	self.usernameTextBox:setPos( margin, y )
	self.usernameTextBox.onChange = function( usernameTextBox )
		if ( usernameTextBox:getText() == "" ) then
			self:resetForm()
		end
	end
	-- BUGBUG: Crash on enter when form is filled out.
	-- self.usernameTextBox.onEnter = signInOrRegister
	self.usernameTextBox.onLostFocus = function()
		if ( self.usernameTextBox:getText() == "" ) then
			return
		end

		self.throbber:enable()

		local username = self.usernameTextBox:getText()
		axis.getAccount( username, function( r, c )
			if ( not self ) then
				return
			end

			self.throbber:disable()

			if ( c == 200 ) then
				self:setSignIn( true )
			elseif ( c == 404 ) then
				self:setSignIn( false )
			end
		end )
	end

	y = y + self.usernameTextBox:getHeight() + 9
	self.passwordTextBox = gui.passwordtextbox( self, "Password Text Box" )
	self.passwordTextBox.onEnter = signInOrRegister
	self.passwordTextBox:setPos( margin, y )

	self.confirmPasswordTextBox = gui.passwordtextbox( self,
	                                                   "Confirm Password Text Box",
	                                                   "Confirm Password" )
	self.confirmPasswordTextBox.onEnter = signInOrRegister
	self.confirmPasswordTextBox:setPos( margin, y )
	self.confirmPasswordTextBox:setVisible( false )

	self.emailTextBox = gui.textbox( self, "Email Text Box", "Email" )
	self.emailTextBox.onEnter = signInOrRegister
	self.emailTextBox:setPos( margin, y )
	self.emailTextBox:setVisible( false )

	y = y + self.emailTextBox:getHeight() + 9
	self.rememberCheckbox = gui.checkbox( self, "Remember Password Checkbox",
	                                            "Remember Password" )
	self.rememberCheckbox:setChecked( axis_remember_password:getBoolean() )
	self.rememberCheckbox:setPos( margin, y )
	self.rememberCheckbox.onCheckedChanged = function( checkbox, checked )
		convar.setConvar( "axis_remember_password", checked and "1" or "0" )
		convar.saveConfig()

		if ( not checked ) then
			if ( filesystem.remove( ".profile" ) ) then
				print( "Removed Axis password." )
			end
		end
	end

	readPassword( self )
end

local function expand( self )
	self:animate( { height = 323 + margin } )
end

local function showRegistrationTextBoxes( self )
	if ( self.register ) then
		return
	end
	self.register = true
	self.confirmPasswordTextBox:setOpacity( 0 )
	self.confirmPasswordTextBox:animate(
		animation.slideDownConfirmPasswordTextBox,
		{
			step = function()
				self:moveToCenter()
			end
		}
	)
	self.confirmPasswordTextBox:setVisible( true )
	self.emailTextBox:setOpacity( 0 )
	self.emailTextBox:animate( animation.slideDownEmailTextBox )
	self.emailTextBox:setVisible( true )

	self.rememberCheckbox:animate( animation.fadeOut, nil, nil, function()
		self.rememberCheckbox:setVisible( false )
		self.rememberCheckbox:setOpacity( 0 )
	end )

	expand( self )
end

local function collapse( self )
	self:animate( { height = 282 } )
end

local function hideRegistrationTextBoxes( self )
	if ( not self.register ) then
		return
	end
	self.register = false
	self.confirmPasswordTextBox:animate(
		animation.slideUpConfirmPasswordTextBox,
		{
			step = function()
				self:moveToCenter()
			end,
			complete = function()
				self.confirmPasswordTextBox:setVisible( false )
				self.confirmPasswordTextBox:setOpacity( 1 )
				self.confirmPasswordTextBox:setPassword( "" )
			end
		}
	)
	self.emailTextBox:animate(
		animation.slideUpEmailTextBox,
		nil,
		nil,
		function()
			self.emailTextBox:setVisible( false )
			self.emailTextBox:setOpacity( 1 )
			self.emailTextBox:setText( "" )
		end
	)

	self.rememberCheckbox:setOpacity( 0 )
	self.rememberCheckbox:animate( animation.fadeIn )
	self.rememberCheckbox:setVisible( true )

	collapse( self )
end

function signindialog:resetForm()
	self:setLabel( "Sign in or Register" )
	hideRegistrationTextBoxes( self )
end

function signindialog:setLabel( label )
	if ( label == "Sign in" ) then
		self.label:animate( animation.fadeOut )

		self.signinLabel:animate( animation.fadeIn )
		self.orLabel:animate( animation.fadeOut )
		self.registerLabel:animate( animation.fadeOut )
	elseif ( label == "Register" ) then
		self.label:animate( animation.fadeOut )

		self.signinLabel:animate( animation.fadeOut )
		self.orLabel:animate( animation.fadeOut )
		self.registerLabel:animate( animation.register )
	elseif ( label == "Sign in or Register" ) then
		self.label:animate( animation.fadeOut )

		self.signinLabel:animate( animation.fadeIn )
		self.orLabel:animate( animation.fadeIn )
		self.registerLabel:animate( animation.registerReset )
	else
		self.label:setOpacity( 0 )
		self.label:setText( label )
		self.label:animate( animation.fadeIn )

		self.signinLabel:animate( animation.fadeOut )
		self.orLabel:animate( animation.fadeOut )
		self.registerLabel:animate( animation.fadeOut )

		self.think = function( signindialog )
			self.label:animate( animation.fadeOut, nil, nil, function()
				self.label:setText( "" )
			end )

			if ( self.register ) then
				self:setLabel( "Register" )
			else
				self:setLabel( "Sign in or Register" )
			end
		end
		self.nextThink = engine.getRealTime() + 3
	end
end

function signindialog:setSignIn( signIn )
	if ( signIn ) then
		self:setLabel( "Sign in" )
		hideRegistrationTextBoxes( self )
	else
		self:setLabel( "Register" )
		showRegistrationTextBoxes( self )
	end
end

gui.register( signindialog, "signindialog" )

if ( g_MainMenu and g_MainMenu.signinDialog ) then
	local visible = g_MainMenu.signinDialog:isVisible()
	g_MainMenu.signinDialog:remove()
	g_MainMenu.signinDialog = nil
	g_MainMenu.signinDialog = gui.signindialog( g_MainMenu )
	g_MainMenu.signinDialog:moveToCenter()
	g_MainMenu.signinDialog:moveToFront()
	if ( visible ) then
		g_MainMenu.signinDialog:activate()
	end
end
