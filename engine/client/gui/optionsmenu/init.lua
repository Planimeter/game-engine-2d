--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Options Menu class
--
--==========================================================================--

class "gui.optionsmenu" ( "gui.tabbedframe" )

local optionsmenu = gui.optionsmenu

function optionsmenu:optionsmenu( parent )
	local name = "Options Menu"
	gui.tabbedframe.tabbedframe( self, parent, name, "Options" )
	self.resizable = false

	local groupName = name .. " Command Button Group"
	local group = gui.commandbuttongroup( self, groupName )

	local buttonName = nil
	buttonName = name .. " OK Button"
	self.okButton = gui.commandbutton( group, buttonName, "OK" )
	self.okButton.onClick = function( commandbutton )
		local panels = self:getTabPanels():getChildren()
		for _, panel in ipairs( panels ) do
			panel:onOK()
		end
		convar.saveConfig()
		self:close()
	end
	buttonName = name .. " Cancel Button"
	self.cancelButton = gui.commandbutton( group, buttonName, "Cancel" )
	self.cancelButton.onClick = function( commandbutton )
		local panels = self:getTabPanels():getChildren()
		for _, panel in ipairs( panels ) do
			panel:onCancel()
		end
		self:close()
	end
	buttonName = name .. " Apply Button"
	self.applyButton = gui.commandbutton( group, buttonName, "Apply" )
	self.applyButton.onClick = function( commandbutton )
		local panels = self:getTabPanels():getChildren()
		for _, panel in ipairs( panels ) do
			panel:onApply()
		end
		convar.saveConfig()
	end

	require( "engine.client.gui.optionsmenu.keyboardoptionspanel" )
	self:addTab( "Keyboard", gui.keyboardoptionspanel )

	require( "engine.client.gui.optionsmenu.videooptionspanel" )
	self:addTab( "Video", gui.videooptionspanel )

	require( "engine.client.gui.optionsmenu.audiooptionspanel" )
	self:addTab( "Audio", gui.audiooptionspanel )

	-- require( "engine.client.gui.optionsmenu.multiplayeroptionspanel" )
	-- self:addTab( "Multiplayer", gui.multiplayeroptionspanel() )
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

local function onReloadScript()
	local mainmenu = g_MainMenu
	if ( mainmenu == nil or not mainmenu.optionsMenu ) then
		return
	end

	local optionsMenu = mainmenu.optionsMenu
	local visible = optionsMenu:isVisible()
	optionsMenu:remove()
	optionsMenu = gui.optionsmenu( mainmenu )
	mainmenu.optionsMenu = optionsMenu
	optionsMenu:moveToCenter()
	if ( visible ) then
		optionsMenu:activate()
	end
end

onReloadScript()
