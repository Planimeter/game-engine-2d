--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: Close Dialog class
--
--==========================================================================--

class "gui.closedialog" ( "gui.frame" )

local closedialog = gui.closedialog

function closedialog:closedialog( parent, name )
	gui.frame.frame( self, parent, "Close Dialog", "Quit Game" )
	self.width  = love.window.toPixels( 546 )
	self.height = love.window.toPixels( 203 )

	self:doModal()

	local label = gui.label(
		self,
		"Close Dialog Label",
		"Are you sure you want to quit the game?"
	)
	label:setPos( love.window.toPixels( 36 ), love.window.toPixels( 86 ) )
	label:setWidth( love.window.toPixels( 252 ) )

	local buttonYes = gui.button( self, "Close Dialog Yes Button", "Yes" )
	buttonYes:setPos(
		love.window.toPixels( 36 ),
		love.window.toPixels( 86 ) + label:getHeight() + love.window.toPixels( 18 )
	)
	buttonYes.onClick = function()
		love._shouldQuit = true
		love.quit()
	end

	local buttonNo = gui.button( self, "Close Dialog No Button", "No" )
	buttonNo:setPos(
		love.window.toPixels( 288 ),
		love.window.toPixels( 86 ) + label:getHeight() + love.window.toPixels( 18 )
	)
	buttonNo.onClick = function()
		self:close()
	end
end
