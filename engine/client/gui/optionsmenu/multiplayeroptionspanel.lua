--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Multiplayer Options Panel class
--
--==========================================================================--

class "gui.multiplayeroptionspanel" ( "gui.frametabpanel" )

local multiplayeroptionspanel = gui.multiplayeroptionspanel

function multiplayeroptionspanel:multiplayeroptionspanel( parent, name )
	name = name or "Multiplayer Options Panel"
	gui.frametabpanel.frametabpanel( self, parent, name )
	local options = {}
	self.options = options
	local c = config.getConfig()

	local e = gui.createElement

	local panel = e( "box", {
		parent = self,
		position = "absolute",
		margin = 36
	}, {
		e( "text", { text = "Name", marginBottom = 9 } ),
		e( "textbox", { position = "static", text = "Unnamed" } )
	} )

	panel:setPos( panel:getMarginLeft(), panel:getMarginTop() )

	-- name = "Play Sound in Desktop"
	-- local desktopSound = gui.checkbox( self, name, name )
	-- self.desktopSound = desktopSound
	-- options.desktopSound = c.sound.desktop
	-- desktopSound:setChecked( c.sound.desktop )
	-- desktopSound.onCheckedChanged = function( checkbox, checked )
	-- 	options.desktopSound = checked
	-- 	c.sound.desktop = checked
	-- end
	-- x = 2 * x + self.name:getWidth()
	-- y = margin + label:getHeight() + marginBottom
	-- desktopSound:setPos( x, y )

	-- name = "Tickrates"
	-- local radiobuttongroup = gui.radiobuttongroup( self, name )
	-- name = "20"
	-- local radiobutton = gui.radiobutton( self, name .. " 1" )
	-- radiobuttongroup:addItem( radiobutton )
	-- x = x
	-- radiobutton:setPos( x, y )
	-- radiobutton:setDefault( true )
end

function multiplayeroptionspanel:activate()
	self:saveControlStates()
end

function multiplayeroptionspanel:onOK()
	self:updateOptions()
end

function multiplayeroptionspanel:onCancel()
	self:resetControlStates()
end

multiplayeroptionspanel.onApply = multiplayeroptionspanel.onOK

function multiplayeroptionspanel:saveControlStates()
	local controls        = {}
	self.controls         = controls
	-- controls.name         = self.name:getText()
	-- controls.desktopSound = self.desktopSound:isChecked()
end

function multiplayeroptionspanel:resetControlStates()
	local controls = self.controls
	-- self.name:setText( controls.name )
	-- self.desktopSound:setChecked( controls.desktopSound )
	table.clear( controls )
end

function multiplayeroptionspanel:updateOptions()
	local options = self.options
	convar.setConvar( "name", options.name )
end
