--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Options Menu class
--
--============================================================================--

class "optionsmenu" ( gui.tabbedframe )

function optionsmenu:optionsmenu( parent )
	local name = "Options Menu"
	gui.tabbedframe.tabbedframe( self, parent, name, "Options" )
	self.resizable = false

	local groupName = name .. " Command Button Group"
	local group = gui.commandbuttongroup( self, groupName )

	local buttonName  = nil
	buttonName        = name .. " OK Button"
	self.okButton     = gui.commandbutton( group, buttonName, "OK" )
	self.okButton.onClick = function( commandbutton )
		local panels = self:getTabPanels():getChildren()
		for _, panel in ipairs( panels ) do
			panel:onOK()
		end
		convar.saveConfig()
		self:close()
	end
	buttonName        = name .. " Cancel Button"
	self.cancelButton = gui.commandbutton( group, buttonName, "Cancel" )
	self.cancelButton.onClick = function( commandbutton )
		local panels = self:getTabPanels():getChildren()
		for _, panel in ipairs( panels ) do
			panel:onCancel()
		end
		self:close()
	end
	buttonName        = name .. " Apply Button"
	self.applyButton  = gui.commandbutton( group, buttonName, "Apply" )
	self.applyButton.onClick = function( commandbutton )
		local panels = self:getTabPanels():getChildren()
		for _, panel in ipairs( panels ) do
			panel:onApply()
		end
		convar.saveConfig()
	end

	require( "engine.client.gui.optionsmenu.keyboardoptionspanel" )
	self:addTab( "Keyboard", gui.keyboardoptionspanel() )

	require( "engine.client.gui.optionsmenu.videooptionspanel" )
	self:addTab( "Video", gui.videooptionspanel() )

	require( "engine.client.gui.optionsmenu.audiooptionspanel" )
	self:addTab( "Audio", gui.audiooptionspanel() )
end

function optionsmenu:activate()
	local panels = self:getTabPanels():getChildren()
	for _, panel in ipairs( panels ) do
		panel:activate()
	end
	gui.frame.activate( self )
end

function optionsmenu:invalidateLayout()
	self:moveToCenter()
	gui.tabbedframe.invalidateLayout( self )
end

gui.register( optionsmenu, "optionsmenu" )

if ( g_MainMenu and g_MainMenu.optionsMenu ) then
	local visible = g_MainMenu.optionsMenu:isVisible()
	g_MainMenu.optionsMenu:remove()
	g_MainMenu.optionsMenu = nil
	g_MainMenu.optionsMenu = gui.optionsmenu( g_MainMenu )
	g_MainMenu.optionsMenu:moveToCenter()
	if ( visible ) then
		g_MainMenu.optionsMenu:activate()
	end
end
