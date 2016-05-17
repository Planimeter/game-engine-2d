--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Test spawning Bows
--
--============================================================================--

local bow = entity.create( "weapon_bow" )
bow:setPosition( localplayer:getPosition() + vector( 0, game.tileSize ) )
bow:spawn()
