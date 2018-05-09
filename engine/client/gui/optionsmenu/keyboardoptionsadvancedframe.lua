--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: Advanced Keyboard Options Frame class
--
--==========================================================================--

class "gui.keyboardoptionsadvancedframe" ( "gui.frame" )

local keyboardoptionsadvancedframe = gui.keyboardoptionsadvancedframe

function keyboardoptionsadvancedframe:keyboardoptionsadvancedframe( parent, name, title )
	name = name or "Advanced Keyboard Options Frame"
	title = title or "Advanced Keyboard Options"
	gui.frame.frame( self, parent, name, title )
	self:setWidth( love.window.toPixels( 480 ) )
	self:setHeight( love.window.toPixels( 147 ) )
	self:setResizable( false )

	name = "Developer Console"
	self.console = gui.checkbox( self, name, "Enable Developer Console" )
	self.console:setChecked( convar.getConvar( "con_enable" ):getBoolean() )
	self.console.onCheckedChanged = function( checkbox, checked )
		convar.setConvar( "con_enable", checked and "1" or "0" )
	end

	local margin = love.window.toPixels( 36 )
	local titleBarHeight = love.window.toPixels( 86 )
	self.console:setPos( margin, titleBarHeight )
end
