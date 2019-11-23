--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Test box
--
--==========================================================================--

local e = gui.createElement

local name = "Quit Game"

class "gui.boxtestframe" ( "gui.frame" )

local boxtestframe = gui.boxtestframe

function boxtestframe:boxtestframe( parent, name, title )
	gui.frame.frame( self, parent, name, title )

	local child = e( "box", {
		parent = self,
		position = "absolute",
		y = 86,
		paddingTop = 0,
		padding = 36
	}, {
		e( "text", {
			marginBottom = 9,
			text = "Are you sure you want to quit the game?",
			-- color = color.white
		} ),
		e( "box", {
			display = "block"
		}, {
			e( "button", {
				display = "inline",
				position = "static",
				-- width = "nil",
				-- height = "nil",
				padding = 14,
				marginRight = 36,
				text = "Quit",
				onClick = function() love._shouldQuit = true; love.quit() end
			} ),
			e( "button", {
				display = "inline",
				position = "static",
				-- width = "nil",
				-- height = "nil",
				padding = 14,
				text = "Cancel",
				onClick = function() self:close() end
			} )
		} )
	} )

	self:setWidth( child:getWidth() )
	self:setHeight( 86 + child:getHeight() )
end

local frame = gui.boxtestframe( nil, name, name )
frame:setRemoveOnClose( true )
frame:moveToCenter()
frame:activate()
