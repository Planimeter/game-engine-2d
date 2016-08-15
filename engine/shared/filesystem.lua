--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Extends the filesystem module
--
--============================================================================--

require( "love.filesystem" )

function love.filesystem.update( dt )
	package.update( dt )
	if ( not _CLIENT ) then return end
	if ( image ) then image.update( dt ) end
	if ( sound ) then sound.update( dt ) end
end
