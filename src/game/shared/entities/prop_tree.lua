--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: prop_tree
--
--============================================================================--

require( "engine.shared.entities.entity" )
require( "game" )

if ( _CLIENT ) then
require( "engine.client.chat" )
end

class "prop_tree" ( "entity" )

function prop_tree:prop_tree()
	entity.entity( self )

	local tileSize = game.tileSize
	local min      = vector()
	local max      = vector( 2 * tileSize, -tileSize )
	self:setCollisionBounds( min, max )

	self:setNetworkVar( "name", "Tree" )

	if ( _CLIENT ) then
		local sprite = graphics.newImage( "images/entities/prop_tree/1.png" )
		self:setSprite( sprite )
	end
end

if ( _CLIENT ) then
	function prop_tree:getOptions()
		return {
			{
				name  = "Chop Down",
				value = self.chopDown
			},
			{
				name  = "Examine",
				value = self.examine
			}
		}
	end
end

function prop_tree:chopDown()
	chat.addText( "Your hands alone really aren't going to cut it." )
end

function prop_tree:examine()
	chat.addText( "Looks like a tree." )
end

entities.linkToClassname( prop_tree, "prop_tree" )
