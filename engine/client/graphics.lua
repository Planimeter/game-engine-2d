--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Extends the graphics module
--
--==========================================================================--

require( "love.graphics" )

local newImage = love.graphics.newImage

local function getHighResolutionVariant( filename )
	local scale     = love.window.getDPIScale()
	local extension = "." .. string.fileextension( filename )
	local hrvariant = string.gsub( filename, extension, "" )
	hrvariant       = hrvariant .. "@" .. scale .. "x" .. extension
	if ( love.filesystem.getInfo( hrvariant ) ~= nil ) then
		return hrvariant
	end
end

function love.graphics.newImage( filename, ... )
	if ( love.window.getDPIScale() > 1 ) then
		local variant = getHighResolutionVariant( filename )
		if ( variant ) then
			filename = variant
		end
	end

	return newImage( filename, ... )
end
