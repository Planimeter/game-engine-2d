--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: vaplayer
--
--==========================================================================--

entities.requireEntity( "player" )

class "vaplayer" ( "player" )

function vaplayer.levelToExperience( level )
	local xp = 0
	for i = 1, level - 1 do
		xp = xp + math.floor( i + 300 * ( 2 ^ ( i / 7 ) ) )
	end
	return math.floor( xp / 4 )
end

function vaplayer.experienceToLevel( xp )
	local level   = 0
	local levelXp = 0
	repeat
		level   = level + 1
		levelXp = vaplayer.levelToExperience( level )
	until ( levelXp > xp )
	return level - 1
end

if ( _CLIENT ) then
	function vaplayer:getOptions()
		if ( self == localplayer ) then
			return
		end

		return {
			{
				name  = "Trade",
				value = function() self:trade() end
			},
			{
				name  = "Examine",
				value = self.examine
			}
		}
	end
end

function vaplayer:trade()
	chat.addText( "Nothing interesting happens." )
end

function vaplayer:examine()
	chat.addText( "Filthy casual." )
end

function vaplayer:vaplayer()
	player.player( self )

	self.stats   = {
		health   = 1154,
		prayer   = 0,
		attack   = 0,
		defense  = 0,
		range    = 0,
		magic    = 1154,
		fishing  = 0,
		cooking  = 0,
		mining   = 0,
		smithing = 0
	}

	local xp = self:getExperience( "health" )
	self:networkNumber( "health", vaplayer.experienceToLevel( xp ) )

	xp = self:getExperience( "magic" )
	self:networkNumber( "mana", vaplayer.experienceToLevel( xp ) )

	self.inventory = {}
end

function vaplayer:addExperience( stat, xp )
	local level = self:getLevel( stat )
	self.stats[ stat ] = self:getExperience( stat ) + xp
	game.call( "shared", "onPlayerGainedExperience", self, stat, xp )

	local newLevel = self:getLevel( stat )
	if ( level ~= newLevel ) then
		game.call( "shared", "onPlayerLeveledUp", self, stat, newLevel )
	end
end

function vaplayer:getExperience( stat )
	return self.stats[ stat ]
end

accessor( vaplayer, "inventory" )

function vaplayer:getLevel( stat )
	if ( stat ) then
		return vaplayer.experienceToLevel( self:getExperience( stat ) )
	end

	local melee = self:getLevel( "attack" )
	local range = math.floor( 1.5 * self:getLevel( "range" ) )
	local magic = math.floor( 1.5 * self:getLevel( "magic" ) )
	local high  = math.max( melee, range, magic )

	local combat = math.floor( 1.3 * high )  +
	               self:getLevel( "health" ) +
	               math.floor( self:getLevel( "prayer" ) / 2 )
	return math.floor( combat / 3 )
end

function vaplayer:give( item, count )
	count = count or 1
	self.inventory[ item ] = ( self.inventory[ item ] or 0 ) + count
	game.call( "shared", "onPlayerGotItem", self, item, count )
end

function vaplayer:hasInventorySpace()
	local total = 0
	for item, count in pairs( self:getInventory() ) do
		local itemdata = _G.item.getData( item )
		if ( not itemdata.stackable ) then
			total = total + count
		else
			total = total + 1
		end
	end
	return total < 28
end

local function moveTo( position )
	return function( character, next )
		character:moveTo( position, next )
	end
end

local function pickup( item )
	return function( vaplayer, next )
		if ( _SERVER ) then
			if ( not vaplayer:hasInventorySpace() ) then
				local text = "You don't have enough inventory space to do that."
				vaplayer:sendText( text )
				return
			end

			local classname = item:getClassname()
			item:remove()
			vaplayer:give( classname )
		end

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
		payload:set( "item", item )
		engine.client.network.sendToServer( payload )
	end
end

if ( _SERVER ) then
	local function onPlayerPickup( payload )
		local player = payload:getPlayer()
		local item   = payload:get( "item" )
		player:pickup( item )
	end

	payload.setHandler( onPlayerPickup, "playerPickup" )
end

entities.linkToClassname( vaplayer, "vaplayer" )
