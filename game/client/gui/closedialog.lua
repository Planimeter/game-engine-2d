--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Close Dialog class
--
--==========================================================================--

class "gui.closedialog" ( "gui.frame" )

local closedialog = gui.closedialog

function closedialog:closedialog( parent, name )
	gui.frame.frame( self, parent, "Close Dialog", "Quit Game" )
	self.width  = 546
	self.height = 203

	self:doModal()

	local text  = "Are you sure you want to quit the game?"
	local label = gui.label(
		self,
		"Close Dialog Label",
		text
	)
	label:setPos( 36, 86 )
	local font = self:getScheme( "font" )
	label:setWidth( font:getWidth( text ) )

	local buttonYes = gui.button( self, "Close Dialog Yes Button", "Yes" )
	buttonYes.height = nil
	buttonYes:setPadding( 14, 18, 13 )
	buttonYes:setPos( 36, 86 + label:getHeight() + 18 )
	buttonYes.onClick = function()
		love._shouldQuit = true
		love.quit()
	end

	local buttonNo = gui.button( self, "Close Dialog No Button", "No" )
	buttonNo.height = nil
	buttonNo:setPadding( 14, 18, 13 )
	buttonNo:setPos( 288, 86 + label:getHeight() + 18 )
	buttonNo.onClick = function()
		self:close()
	end
end
