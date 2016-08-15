--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Chat interface
--
--============================================================================--

class( "chat" )

function chat.addText( ... )
	local args = { ... }
	for i = 1, select( "#", ... ) do
		args[ i ] = tostring( args[ i ] )
	end

	local chat = g_Chat.output
	local text = table.concat( args, "\t" )
	chat:activate()
	chat:insertText( text .. "\n" )

	local readingtime = math.max( string.readingtime( text ), 5 )
	chat:setHideTime( love.timer.getTime() + readingtime )
end
