--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: prop_ore_rock
--
--============================================================================--

require( "engine.shared.entities.entity" )
require( "game" )

class "prop_ore_rock" ( "entity" )

function prop_ore_rock:prop_ore_rock()
	entity.entity( self )

	self:setNetworkVar( "name", "Ore Rock" )

	if ( _CLIENT ) then
		local sprite = graphics.newImage( "images/entities/prop_ore_rock.png" )
		self:setSprite( sprite )
	end
end

if ( _CLIENT ) then
	function prop_ore_rock:getOptions()
		return {
			{
				name  = "Pick",
				value = function() self:pick() end
			},
			{
				name  = "Examine",
				value = self.examine
			}
		}
	end
end

function prop_ore_rock:pick()
end

function prop_ore_rock:examine()
	chat.addText( "This rock contains ore." )
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
