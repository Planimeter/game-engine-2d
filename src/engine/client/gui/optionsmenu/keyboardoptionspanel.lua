--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Keyboard Options Panel class
--
--============================================================================--

require( "engine.client.gui.optionsmenu.bindlistpanel" )
require( "engine.client.gui.optionsmenu.keyboardoptionscommandbuttongroup" )

class "keyboardoptionspanel" ( gui.frametabpanel )

function keyboardoptionspanel:keyboardoptionspanel()
	gui.frametabpanel.frametabpanel( self, nil, "Keyboard Options Panel" )

	self.bindList = gui.bindlistpanel( self )
	local height = 348 - 24
	self.bindList:setSize( 640 - 48, height )
	self.bindList:setPos( 24, 24 )
	self.bindList:readBinds()

	local name      = "Keyboard Options"
	local groupName = name .. " Command Button Group"
	local group     = gui.keyboardoptionscommandbuttongroup( self, groupName )

	local buttonName       = name .. " Use Defaults Button"
	self.useDefaultsButton = gui.commandbutton( group, buttonName, "Use Defaults" )
	self.useDefaultsButton.onClick = function( commandbutton )
		print( "IMPLEMENT ME: Default bindings." )
	end
	buttonName                  = name .. " Advanced Button"
	self.advancedButton         = gui.commandbutton( group, buttonName, "Advanced" )
	self.advancedButton.onClick = function( commandbutton )
		print( "IMPLEMENT ME: Advanced Modal." )
	end
end

function keyboardoptionspanel:activate()
end

function keyboardoptionspanel:onOK()
end

function keyboardoptionspanel:onCancel()
end

function keyboardoptionspanel:onApply()
end

gui.register( keyboardoptionspanel, "keyboardoptionspanel" )
