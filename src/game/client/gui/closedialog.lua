--========= Copyright © 2013-2014, Planimeter, All rights reserved. ==========--
--
-- Purpose: Close Dialog class
--
--============================================================================--

class "closedialog" ( gui.frame )

function closedialog:closedialog( parent, name )
	gui.frame.frame( self, parent, "Close Dialog", "Quit Game" )
	self.width  = 546
	self.height = 203

	self:doModal()

	local label = gui.label( self,
							 "Close Dialog Label",
							 "Are you sure you want to quit the game?" )
	label:setPos( 36, 86 )
	label:setWidth( 252 )

	local buttonYes = gui.button( self, "Close Dialog Yes Button", "Yes" )
	buttonYes:setPos( 36, 86 + label:getHeight() + 18 )
	buttonYes.onClick = function()
		engine.setRequestingShutdown( true )
		engine.quit()
	end
	
	local buttonNo = gui.button( self, "Close Dialog No Button", "No" )
	buttonNo:setPos( 288, 86 + label:getHeight() + 18 )
	buttonNo.onClick = function()
		self:close()
	end
end

gui.register( closedialog, "closedialog" )
