--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: vaplayer
--
--============================================================================--

require( "engine.shared.entities.player" )

class "vaplayer" ( "player" )

function vaplayer:vaplayer()
	player.player( self )

	self.inventory = {}
end

function vaplayer:getInventory()
	return self.inventory
end

function vaplayer:give( item, count )
	self.inventory[ item ] = ( self.inventory[ item ] or 0 ) + ( count or 1 )
	game.call( "shared", "onPlayerGotItem", self, item, count )
end

local function moveTo( position )
	return function( character, next )
		character:moveTo( position, next )
	end
end

local function pickup( item )
	return function( vaplayer, next )
		local classname = item:getClassname()
		item:remove()
		vaplayer:give( classname )
		next()
	end
end

function vaplayer:pickup( item )
	self:removeTasks()

	local position = item:getPosition()
	self:addTask( moveTo( position ) )
	self:addTask( pickup( item ) )

	if ( _CLIENT and not _SERVER ) then
		local payload = payload( "playerPickup" )
		payload:set( "item", item.entIndex )
		networkclient.sendToServer( payload )
	end
end

if ( _SERVER ) then
	local function onPlayerPickup( payload )
		local player = payload:getPlayer()
		local item   = entity.getByEntIndex( payload:get( "item" ) )
		player:pickup( item )
	end

	payload.setHandler( onPlayerPickup, "playerPickup" )
end

entities.linkToClassname( vaplayer, "vaplayer" )
