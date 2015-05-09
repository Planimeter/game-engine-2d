--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Test Frame class
--
--============================================================================--

class "advancedoptions" ( gui.tabbedframe )

function advancedoptions:advancedoptions( parent, name )
	name = "Advanced Options"
	gui.tabbedframe.tabbedframe( self, parent, name, name )
	self.resizable = false
	self.width = 600
	self.height = 300

	self:createTestPanels()
end

function advancedoptions:createTestPanels()
	local name = self:getName()
	local panelName = ""
	local function getDebugName()
		return name .. " " .. panelName
	end

	local tab = gui.frametabpanel()


	panelName = "Command Button Group"
	local commandbuttongroup = gui.commandbuttongroup( self, getDebugName() )

	panelName = "Command Button"
	local commandbutton = nil
	local parent = commandbuttongroup
	local item = getDebugName()
	local onClick = function()
		self:close()
	end
	commandbutton = gui.commandbutton( parent, item .. " 1", "OK" )
	commandbutton.onClick = function(commandbutton)
		convar.saveConfig()
		print("Developer settings updated.")
		self:close()
	end
	commandbutton = gui.commandbutton( parent, item .. " 2", "Cancel" )
	commandbutton.onClick = function(commandbutton)
		self:close()
	end

	local margin = 36

	panelName = "Developer Console Checkbox"
	local developerconsolecheckbox = gui.checkbox( tab, getDebugName(),
		"Enable Developer Console" )
	developerconsolecheckbox:setChecked( convar.getConvar( "dev_developer_console" ) )
	developerconsolecheckbox.onCheckedChanged = function( checkbox, checked )
		--convar.setConvar( "dev_developer_console", checked )
		if(checked == true) then
			convar.setConvar( "dev_developer_console", 1 )
			print("Developer console enabled.")
			convar.saveConfig()
		else 
			convar.setConvar( "dev_developer_console", 0 )
			print("Developer console disabled.")
			convar.saveConfig()
		end
	end

	x = margin
	y = margin - 3 + 8
	developerconsolecheckbox:setPos( x, y )
	local checkboxHeight = developerconsolecheckbox:getHeight()

	self:addTab( "Developer Settings", tab, true )
end

gui.register( advancedoptions, "advancedoptions" )

if ( g_MainMenu and g_MainMenu.advancedoptions ) then
	local visible = g_MainMenu.advancedoptions:isVisible()
	g_MainMenu.advancedoptions:remove()
	g_MainMenu.advancedoptions = nil
	g_MainMenu.advancedoptions = gui.advancedoptions( g_MainMenu )
	g_MainMenu.advancedoptions:moveToCenter()
	if ( visible ) then
		g_MainMenu.advancedoptions:activate()
	end
end
