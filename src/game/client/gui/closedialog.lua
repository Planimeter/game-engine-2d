--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Close Dialog class
--
--============================================================================--

class "closedialog" ( gui.frame )

function closedialog:closedialog( parent, name )
	gui.frame.frame( self, parent, "Close Dialog", "Quit Game" )
	self.width  = point( 546 )
	self.height = point( 203 )

	self:doModal()

	local label = gui.label(
		self,
		"Close Dialog Label",
		"Are you sure you want to quit the game?"
	)
	local margin         = point( 36 )
	local titleBarHeight = point( 86 )
	label:setPos( margin, titleBarHeight )
	label:setWidth( point( 252 ) )

	local buttonYes    = gui.button( self, "Close Dialog Yes Button", "Yes" )
	local marginBottom = point( 18 )
	buttonYes:setPos(
		margin,
		titleBarHeight + label:getHeight() + marginBottom
	)
	buttonYes.onClick = function()
		engine.setRequestingShutdown( true )
		engine.quit()
	end

	local buttonNo = gui.button( self, "Close Dialog No Button", "No" )
	buttonNo:setPos(
		point( 288 ),
		titleBarHeight + label:getHeight() + marginBottom
	)
	buttonNo.onClick = function()
		self:close()
	end
end

gui.register( closedialog, "closedialog" )
