--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: prop_chest
--
--==========================================================================--

entities.require( "entity" )
require( "game" )

if ( _CLIENT ) then
	require( "engine.client.chat" )
end

class "prop_chest" ( "entity" )

function prop_chest:prop_chest()
	entity.entity( self )

	self:setNetworkVar( "name", "Chest" )

	if ( _CLIENT ) then
		local filename = "images/entities/prop_chest.png"
		local sprite   = love.graphics.newImage( filename )
		sprite:setFilter( "nearest", "nearest" )
		self:setSprite( sprite )
	end

	self.inventory = {}
end

if ( _CLIENT ) then
	function prop_chest:getOptions()
		return {
			{ name = "Search",  value = function() self:search()  end },
			{ name = "Examine", value = function() self:examine() end }
		}
	end

	local function moveTo( position )
		return function( character, next )
			character:moveTo( position, next )
		end
	end

	local function use( entity )
		return function( player, next )
			local payload = payload( "playerUse" )
			payload:set( "entity", entity )
			payload:set( "value",  nil )
			payload:sendToServer()

			next()
		end
	end

	function prop_chest:search()
		-- Stop everything
		localplayer:removeTasks()

		-- Walk to the front of the chest
		local position = self:getPosition() + vector( 0, game.tileSize )
		localplayer:addTask( moveTo( position ) )

		-- Use it
		localplayer:addTask( use( self ) )
	end

	function prop_chest:examine()
		chat.addText( "I wonder what's inside." )
	end
end

function prop_chest:spawn()
	entity.spawn( self )

	local tileSize = game.tileSize
	local min      = vector()
	local max      = vector( tileSize, -tileSize )
	self:initializePhysics()
	self:setCollisionBounds( min, max )
end

function prop_chest:use( activator, value )
	activator:sendText( "You search the chest but find nothing." )
end

entities.linkToClassname( prop_chest, "prop_chest" )
