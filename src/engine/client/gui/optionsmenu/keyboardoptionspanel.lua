--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Keyboard Options Panel class
--
--============================================================================--

class "keyboardoptionspanel" ( gui.frametabpanel )

function keyboardoptionspanel:keyboardoptionspanel()
	gui.frametabpanel.frametabpanel( self, nil, "Keyboard Options Panel" )
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
