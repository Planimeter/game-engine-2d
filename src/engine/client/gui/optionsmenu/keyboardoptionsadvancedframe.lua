--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Advanced Keyboard Options Frame class
--
--============================================================================--

class "keyboardoptionsadvancedframe" ( gui.frame )

function keyboardoptionsadvancedframe:keyboardoptionsadvancedframe( parent )
	local name = "Advanced Keyboard Options"
	gui.frame.frame( self, parent, name .. " Frame", name )
	self:setWidth( point( 480 ) )
	self:setHeight( point( 147 ) )
	self:setResizable( false )

	name = "Developer Console"
	self.console = gui.checkbox( self, name, "Enable Developer Console" )
	self.console:setChecked( convar.getConvar( "con_enable" ):getBoolean() )
	self.console.onCheckedChanged = function( checkbox, checked )
		convar.setConvar( "con_enable", checked and "1" or "0" )
	end

	local margin = point( 36 )
	local titleBarHeight = point( 86 )
	self.console:setPos( margin, titleBarHeight )
end

gui.register( keyboardoptionsadvancedframe, "keyboardoptionsadvancedframe" )
