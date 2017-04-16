--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: GUI autoloader
--
--============================================================================--

local error        = error
local ipairs       = ipairs
local pcall        = pcall
local rawget       = rawget
local require      = require
local setmetatable = setmetatable
local string       = string
local _G           = _G

module( "gui" )

setmetatable( _M, {
	__index = function( t, k )
		local privateMember = string.sub( k, 1, 1 ) == "_"
		if ( privateMember ) then return end

		for _, module in ipairs( {
			"game.client",
			"engine.client"
		} ) do
			local library = module .. ".gui." .. k
			local success, err = pcall( require, library )
			if ( success ) then
				break
			else
				local message = "module '" .. library .. "' not found:"
				local notFound = string.find( err, message ) ~= 1
				if ( notFound ) then
					error( err, 2 )
				end
			end
		end

		local v = rawget( t, k )
		if ( v ~= nil ) then return v end
	end
} )
