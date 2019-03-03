--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: vanpc
--
--==========================================================================--

entities.require( "npc" )

if ( _CLIENT ) then
	require( "engine.client.chat" )
end

class "vanpc" ( "npc" )

function vanpc:vanpc()
	npc.npc( self )
	self:setNetworkVar( "name", "Example NPC" )
end

if ( _CLIENT ) then
	function vanpc:getOptions()
		return {
			{ name = "Talk to", value = function() self:talkTo() end },
			{ name = "Examine", value = function() self:examine() end }
		}
	end

	local function moveTo( position )
		return function( character, next )
			character:moveTo( position, next )
		end
	end

	local function talkTo( entity )
		return function( player, next )
			local payload = payload( "npcTalkTo" )
			payload:set( "npc", entity )
			payload:set( "dialogue", nil )
			payload:sendToServer()

			next()
		end
	end

	function vanpc:talkTo()
		-- Stop everything
		localplayer:removeTasks()

		-- Walk up to the NPC
		local pos1  = localplayer:getPosition()
		local pos2  = self:getPosition()
		local tiles = path.getPath( pos1, pos2 )
		if ( tiles and #tiles > 1 ) then
			local nearestTile = tiles[ #tiles - 1 ]
			localplayer:addTask( moveTo( nearestTile ) )
		end

		-- Talk to it
		localplayer:addTask( talkTo( self ) )
	end

	function vanpc:examine()
		chat.addText( "Some guy." )
	end
end

if ( _SERVER ) then
	local function onNPCTalkTo( payload )
		local player    = payload:getPlayer()
		local npc       = payload:get( "npc" )
		local dialogue  = payload:get( "dialogue" )

		local canTalkTo = game.call(
			"server", "onNPCTalkTo", npc, player, dialogue
		)
		if ( canTalkTo == false ) then
			return
		end

		npc:onTalkTo( player, dialogue )
	end

	payload.setHandler( onNPCTalkTo, "npcTalkTo" )

	function vanpc:onTalkTo( vaplayer, dialogue )
		local name = vaplayer:getName()
		vaplayer:sendText( "Hello, " .. name .. "!" )
	end
end

vanpc.dialogue = vanpc.dialogue or {}
local dialogue = vanpc.dialogue

table.insert( dialogue, {
	index   = 1,
	text    = "Are you a boy? Or are you a girl?",
	options = { 2, 3 }
} )

table.insert( dialogue, {
	index   = 2,
	text    = "Boy",
	next    = 4
} )

table.insert( dialogue, {
	index   = 3,
	text    = "Girl",
	next    = 4
} )

table.insert( dialogue, {
	index   = 4,
	text    = "Ah yes. We've been expecting you."
} )

entities.linkToClassname( vanpc, "vanpc" )
