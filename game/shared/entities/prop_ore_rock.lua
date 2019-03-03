--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: prop_ore_rock
--
--==========================================================================--

entities.require( "entity" )
require( "game" )

if ( _CLIENT ) then
	require( "engine.client.chat" )
end

class "prop_ore_rock" ( "entity" )

function prop_ore_rock:prop_ore_rock()
	entity.entity( self )

	self:setNetworkVar( "name", "Ore Rock" )

	if ( _CLIENT ) then
		local filename = "images/entities/prop_ore_rock.png"
		local sprite   = love.graphics.newImage( filename )
		sprite:setFilter( "nearest", "nearest" )
		self:setSprite( sprite )
	end

	self:setDrawShadow( false )
end

if ( _CLIENT ) then
	function prop_ore_rock:getOptions()
		return {
			{ name = "Pick",    value = function() self:pick()    end },
			{ name = "Examine", value = function() self:examine() end }
		}
	end

	function prop_ore_rock:pick()
		chat.addText( "Nothing interesting happens." )
	end

	function prop_ore_rock:examine()
		chat.addText( "This rock contains ore." )
	end
end

function prop_ore_rock:spawn()
	entity.spawn( self )

	local tileSize = game.tileSize
	local min      = vector()
	local max      = vector( tileSize, -tileSize )
	self:initializePhysics()
	self:setCollisionBounds( min, max )
end

entities.linkToClassname( prop_ore_rock, "prop_ore_rock" )
