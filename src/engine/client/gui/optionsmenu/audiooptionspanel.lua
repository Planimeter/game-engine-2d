--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Audio Options Panel class
--
--============================================================================--

class "audiooptionspanel" ( gui.frametabpanel )

function audiooptionspanel:audiooptionspanel()
	gui.frametabpanel.frametabpanel( self, nil, "Audio Options Panel" )
end

function audiooptionspanel:activate()
	self:saveControlStates()
end

function audiooptionspanel:onOK()
end

function audiooptionspanel:onCancel()
	self:resetControlStates()
end

audiooptionspanel.onApply = audiooptionspanel.onOK

function audiooptionspanel:saveControlStates()
	local controls = {}
	self.controls  = controls
end

function audiooptionspanel:resetControlStates()
	local controls = self.controls
	table.clear( controls )
end

gui.register( audiooptionspanel, "audiooptionspanel" )
