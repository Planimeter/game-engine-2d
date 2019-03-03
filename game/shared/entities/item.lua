--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: item
--
--==========================================================================--

entities.require( "entity" )
-- require( "game" )

if ( _CLIENT ) then
	require( "engine.client.chat" )
end

class "item" ( "entity" )

function item.getClass( classname )
	entities.require( classname )
	local classmap = entities.getClassMap()
	return classmap[ classname ]
end

item.data = {
	name  = "Unknown Item",
	image = "images/error.png"
}

function item:item()
	entity.entity( self )

	-- local tileSize = game.tileSize
	-- local min      = vector()
	-- local max      = vector( tileSize, -tileSize )
	-- self:setCollisionBounds( min, max )

	local name = self.data.name
	self:setNetworkVar( "name", name )

	if ( _CLIENT ) then
		local filename = self.data.image
		local sprite   = love.graphics.newImage( filename )
		sprite:setFilter( "nearest", "nearest" )
		self:setSprite( sprite )
	end
end

if ( _CLIENT ) then
	function item:getOptions()
		return {
			{ name = "Pickup",  value = function() self:pickup()  end },
			{ name = "Examine", value = function() self:examine() end }
		}
	end

	function item:getInventoryOptions()
		return {
			{
				name  = "Use",
				value = function()
					g_Inventory:select( self.__type )
				end
			},
			{ name = "Drop",    value = function() self:drop()    end },
			{ name = "Examine", value = function() self:examine() end }
		}
	end

	function item:pickup()
		localplayer:pickup( self )
	end

	function item:drop()
		localplayer:drop( self.__type )
	end

	function item:examine()
		chat.addText( "It's an item." )
	end
end

function item:setCollisionBounds( min, max )
	entity.setCollisionBounds( self, min, max )

	local body = self:getBody()
	if ( body == nil ) then
		return
	end

	local fixtures = body:getFixtures()
	local fixture  = fixtures[ 1 ]
	if ( fixture ) then
		fixture:setMask( 6 --[[ COLLISION_GROUP_PLAYER ]] )
	end
end

function item:use( activator, value )
	chat.addText( "Nothing interesting happens." )
end

function item:useItem( activator, value )
	chat.addText( "Nothing interesting happens." )
end
