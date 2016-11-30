--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Close Dialog class
--
--============================================================================--

local gui   = gui
local point = point

class "gui.closedialog" ( "gui.frame" )

function _M:closedialog( parent, name )
	gui.frame.frame( self, parent, "Close Dialog", "Quit Game" )
	self.width  = point( 546 )
	self.height = point( 203 )

	self:doModal()

	local label = gui.label(
		self,
		"Close Dialog Label",
		"Are you sure you want to quit the game?"
	)
	label:setPos( point( 36 ), point( 86 ) )
	label:setWidth( point( 252 ) )

	local buttonYes = gui.button( self, "Close Dialog Yes Button", "Yes" )
	buttonYes:setPos(
		point( 36 ),
		point( 86 ) + label:getHeight() + point( 18 )
	)
	buttonYes.onClick = function()
		love._quit = true
		love.quit()
	end

	local buttonNo = gui.button( self, "Close Dialog No Button", "No" )
	buttonNo:setPos(
		point( 288 ),
		point( 86 ) + label:getHeight() + point( 18 )
	)
	buttonNo.onClick = function()
		self:close()
	end
end
