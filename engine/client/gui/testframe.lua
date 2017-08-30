--=========== Copyright © 2017, Planimeter, All rights reserved. ===========--
--
-- Purpose: Test Frame class
--
--==========================================================================--

class "gui.testframe" ( "gui.tabbedframe" )

local testframe = gui.testframe

function testframe:testframe( parent, name )
	name = "Test Frame"
	gui.tabbedframe.tabbedframe( self, parent, name, name )
	self.resizable = false

	self:createTestPanels()
end

function testframe:createTestPanels()
	local name = self:getName()
	local panelName = ""
	local function getDebugName()
		return name .. " " .. panelName
	end

	local tab = gui.frametabpanel()

	panelName = "Scrollable Panel"
	local panel = gui.scrollablepanel( tab, getDebugName() )
	panel.invalidateLayout = function( self )
		self:setSize( self:getParent():getSize() )
		gui.panel.invalidateLayout( self )
	end
	panel:setInnerHeight( love.window.toPixels( 1386 ) )
	panel = panel:getInnerPanel()

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
	commandbutton.onClick = onClick
	commandbutton = gui.commandbutton( parent, item .. " 2", "Cancel" )
	commandbutton.onClick = onClick
	commandbutton = gui.commandbutton( parent, item .. " 3", "Apply" )

	panelName = "Text Box"
	local textbox = gui.textbox( panel, getDebugName() )
	local margin = love.window.toPixels( 36 )
	local x = margin
	local y = margin
	textbox:setPos( x, y )
	local textboxWidth = textbox:getWidth()
	local textboxHeight = textbox:getHeight()

	panelName = "Password Text Box"
	local passwordtextbox = gui.passwordtextbox( panel, getDebugName() )
	y = y + textboxHeight + love.window.toPixels( 9 )
	passwordtextbox:setPos( x, y )
	passwordtextbox.onChange = function( passwordtextbox )
		textbox:setText( passwordtextbox:getPassword() )
	end
	local passwordtextboxWidth = passwordtextbox:getWidth()
	local passwordtextboxHeight = passwordtextbox:getHeight()

	panelName = "Button"
	local button = gui.button( panel, getDebugName() )
	y = y + passwordtextboxHeight + love.window.toPixels( 9 )
	button:setPos( x, y )
	local buttonHeight = button:getHeight()

	panelName = "Label"
	local label = gui.label( panel, getDebugName() )
	y = y + button:getHeight() + love.window.toPixels( 9 )
	label:setPos( x, y )
	local labelHeight = label:getHeight()

	panelName = "Drop-Down List"
	local dropdownlist = gui.dropdownlist( panel, getDebugName() )
	y = y + labelHeight + love.window.toPixels( 9 )
	dropdownlist:setPos( x, y )
	local dropdownlistHeight = dropdownlist:getHeight()

	panelName = "Drop-Down List Item"
	local dropdownlistitem = nil
	item = getDebugName()
	dropdownlistitem = gui.dropdownlistitem( item .. " 1", panelName .. " 1" )
	dropdownlist:addItem( dropdownlistitem )
	dropdownlistitem = gui.dropdownlistitem( item .. " 2", panelName .. " 2" )
	dropdownlist:addItem( dropdownlistitem )
	-- dropdownlistitem = gui.dropdownlistitem( item .. " 3", panelName .. " 3" )
	-- dropdownlist:addItem( dropdownlistitem )

	panelName = "Slider"
	local slider = gui.slider( panel, getDebugName() )
	y = y + dropdownlistHeight + love.window.toPixels( 18 )
	slider:setPos( x, y )

	panelName = "Checkbox"
	local checkbox = gui.checkbox( panel, getDebugName() )
	x = x + textboxWidth + margin
	y = margin + labelHeight - love.window.toPixels( 3 ) + love.window.toPixels( 8 )
	checkbox:setPos( x, y )
	checkbox:setChecked( true )
	local checkboxHeight = checkbox:getHeight()

	panelName = "Radio Button Group"
	local radiobuttongroup = gui.radiobuttongroup( panel, getDebugName() )
	panelName = "Radio Button"
	local radiobutton = gui.radiobutton( panel, getDebugName() .. " 1" )
	radiobuttongroup:addItem( radiobutton )
	local radiobuttonHeight = radiobutton:getHeight()
	y = y + checkboxHeight + love.window.toPixels( 9 ) + passwordtextboxHeight - radiobuttonHeight
	radiobutton:setPos( x, y )
	radiobutton:setDefault( true )

	local image = gui.imagepanel( panel, "Image", nil )
	x = margin
	image:setPos( x, love.window.toPixels( 1386 ) - margin - love.window.toPixels( 32 ) )
	image:setSize( love.window.toPixels( 32 ), love.window.toPixels( 32 ) )

	self:addTab( "Tab", tab, true )
end

local function restorePanel()
	local testFrame = g_MainMenu and g_MainMenu.testFrame
	if ( testFrame == nil ) then
		return
	end

	local visible = testFrame:isVisible()
	testFrame:remove()
	testFrame = gui.testframe( g_MainMenu )
	g_MainMenu.testFrame = testFrame
	testFrame:moveToCenter()
	if ( visible ) then
		gamemenu:activate()
	end
end

restorePanel()
