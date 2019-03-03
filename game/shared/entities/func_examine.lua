--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: func_examine
--
--==========================================================================--

entities.require( "entity" )
require( "game" )

if ( _CLIENT ) then
	require( "engine.client.chat" )
end

class "func_examine" ( "entity" )

function func_examine:func_examine()
	entity.entity( self )
end

if ( _CLIENT ) then
	function func_examine:getOptions()
		return {
			{
				name  = "Examine",
				value = function() self:examine() end
			}
		}
	end

	function func_examine:examine()
		local properties = self:getProperties()
		chat.addText( properties[ "text" ] )
	end
end

function func_examine:spawn()
	entity.spawn( self )

	local tileSize = game.tileSize
	local min      = vector()
	local max      = vector( tileSize, -tileSize )
	self:initializePhysics()
	self:setCollisionBounds( min, max )
end

entities.linkToClassname( func_examine, "func_examine" )
