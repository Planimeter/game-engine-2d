--=========== Copyright © 2017, Planimeter, All rights reserved. ===========--
--
-- Purpose: Keyboard Options Panel class
--
--==========================================================================--

require( "engine.client.gui.optionsmenu.bindlistpanel" )
require( "engine.client.gui.optionsmenu.keyboardoptionscommandbuttongroup" )
require( "engine.client.gui.optionsmenu.keyboardoptionsadvancedframe" )

class "gui.keyboardoptionspanel" ( "gui.frametabpanel" )

local keyboardoptionspanel = gui.keyboardoptionspanel

function keyboardoptionspanel:keyboardoptionspanel( parent, name )
	parent = parent or nil
	name = name or "Keyboard Options Panel"
	gui.frametabpanel.frametabpanel( self, parent, name )

	self.bindList = gui.bindlistpanel( self )
	local margin = love.window.toPixels( 24 )
	local height = love.window.toPixels( 348 ) - margin
	self.bindList:setSize( love.window.toPixels( 640 ) - 2 * margin, height )
	self.bindList:setPos( margin, margin )
	self.bindList:readBinds()

	local name = "Keyboard Options"
	local groupName = name .. " Command Button Group"
	local group = gui.keyboardoptionscommandbuttongroup( self, groupName )

	local buttonName = name .. " Use Defaults Button"
	self.useDefaultsButton = gui.commandbutton( group, buttonName, "Use Defaults" )
	self.useDefaultsButton.onClick = function( commandbutton )
		self.bindList:useDefaults()
	end
	buttonName = name .. " Advanced Button"
	self.advancedButton = gui.commandbutton( group, buttonName, "Advanced" )
	self.advancedButton.onClick = function( commandbutton )
		if ( self.advancedOptions == nil ) then
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
