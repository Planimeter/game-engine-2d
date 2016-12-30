--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Audio Options Panel class
--
--============================================================================--

class "gui.audiooptionspanel" ( "gui.frametabpanel" )

function audiooptionspanel:audiooptionspanel()
	gui.frametabpanel.frametabpanel( self, nil, "Audio Options Panel" )
	local options = {}
	self.options = options
	local c = config.getConfig()

	local name = "Master Volume"
	local label = gui.label( self, name, name )
	local margin = point( 36 )
	local x = margin
	local y = margin
	label:setPos( x, y )
	label:setFont( self:getScheme( "fontBold" ) )

	name = "Master Volume Slider"
	local masterVolume = gui.slider( self, name )
	self.masterVolume = masterVolume
	options.masterVolume = c.sound.volume
	masterVolume:setMax( 1 )
	masterVolume:setValue( c.sound.volume )
	masterVolume.onValueChanged = function( slider, oldValue, newValue )
		options.masterVolume = newValue
		c.sound.volume = newValue
	end
	local marginBottom = point( 9 )
	y = y + label:getHeight() + marginBottom
	masterVolume:setPos( x, y )

	name = "Play Sound in Desktop"
	local desktopSound = gui.checkbox( self, name, name )
	self.desktopSound = desktopSound
	options.desktopSound = c.sound.desktop
	desktopSound:setChecked( c.sound.desktop )
	desktopSound.onCheckedChanged = function( checkbox, checked )
		options.desktopSound = checked
		c.sound.desktop = checked
	end
	x = 2 * x + masterVolume:getWidth()
	y = margin + label:getHeight() + marginBottom
	desktopSound:setPos( x, y )
end

function audiooptionspanel:activate()
	self:saveControlStates()
end

function audiooptionspanel:onOK()
	self:updateSound()
end

function audiooptionspanel:onCancel()
	self:resetControlStates()
end

audiooptionspanel.onApply = audiooptionspanel.onOK

function audiooptionspanel:saveControlStates()
	local controls        = {}
	self.controls         = controls
	controls.masterVolume = self.masterVolume:getValue()
	controls.desktopSound = self.desktopSound:isChecked()
end

function audiooptionspanel:resetControlStates()
	local controls = self.controls
	self.masterVolume:setValue( controls.masterVolume )
	self.desktopSound:setChecked( controls.desktopSound )
	table.clear( controls )
end

function audiooptionspanel:updateSound()
	local options = self.options
	convar.setConvar( "snd_volume", options.masterVolume )
	convar.setConvar( "snd_desktop", options.desktopSound and 1 or 0 )
end


