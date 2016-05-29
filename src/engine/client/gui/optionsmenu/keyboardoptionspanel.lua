--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Keyboard Options Panel class
--
--============================================================================--

require( "engine.client.gui.optionsmenu.bindlistpanel" )
require( "engine.client.gui.optionsmenu.keyboardoptionscommandbuttongroup" )
require( "engine.client.gui.optionsmenu.keyboardoptionsadvancedframe" )

class "keyboardoptionspanel" ( gui.frametabpanel )

function keyboardoptionspanel:keyboardoptionspanel()
	gui.frametabpanel.frametabpanel( self, nil, "Keyboard Options Panel" )

	self.bindList = gui.bindlistpanel( self )
	local height = point( 348 ) - point( 24 )
	self.bindList:setSize( point( 640 ) - point( 48 ), height )
	self.bindList:setPos( point( 24 ), point( 24 ) )
	self.bindList:readBinds()

	local name      = "Keyboard Options"
	local groupName = name .. " Command Button Group"
	local group     = gui.keyboardoptionscommandbuttongroup( self, groupName )

	local buttonName       = name .. " Use Defaults Button"
	self.useDefaultsButton = gui.commandbutton( group, buttonName, "Use Defaults" )
	self.useDefaultsButton.onClick = function( commandbutton )
		self.bindList:useDefaults()
	end
	buttonName                  = name .. " Advanced Button"
	self.advancedButton         = gui.commandbutton( group, buttonName, "Advanced" )
	self.advancedButton.onClick = function( commandbutton )
		if ( not self.advancedOptions ) then
			self.advancedOptions = gui.keyboardoptionsadvancedframe( g_MainMenu )
			self.advancedOptions:activate()
			self.advancedOptions:moveToCenter()
		else
			self.advancedOptions:activate()
		end
	end
end

function keyboardoptionspanel:activate()
end

function keyboardoptionspanel:onOK()
	self.bindList:saveBinds()
end

function keyboardoptionspanel:onCancel()
	local innerPanel = self.bindList:getInnerPanel()
	innerPanel:removeChildren()
	self.bindList:readBinds()
end

keyboardoptionspanel.onApply = keyboardoptionspanel.onOK

gui.register( keyboardoptionspanel, "keyboardoptionspanel" )
