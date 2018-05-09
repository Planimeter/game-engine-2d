--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: Extends the graphics module
--
--==========================================================================--

require( "love.graphics" )

local newImage = love.graphics.newImage

local function getHighResolutionVariant( filename )
	local extension = "." .. string.fileextension( filename )
	local hrvariant = string.gsub( filename, extension, "" )
	hrvariant       = hrvariant .. "@2x" .. extension
	if ( love.filesystem.exists( hrvariant ) ) then
		return hrvariant
	end
end

function love.graphics.newImage( filename )
	if ( love.window.getPixelScale() > 1 ) then
		local variant = getHighResolutionVariant( filename )
		if ( variant ) then
			filename = variant
		end
	end

	return newImage( filename )
end
