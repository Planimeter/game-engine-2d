--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Sound class
--
--============================================================================--

-- These values are preserved during real-time scripting.
local sounds = sound and sound.sounds or {}

local audio = love.audio

class( "sound" )

sound.sounds = sounds

local modtime  = nil
local errormsg = nil

function sound.update( dt )
	for filename, s in pairs( sounds ) do
		modtime, errormsg = filesystem.getLastModified( filename )
		if ( errormsg == nil and modtime ~= s.modtime ) then
			-- s.sound = nil
			print( "Reloading " .. filename .. "..." )
			local status, ret = pcall( audio.newSource, filename )
			s.modtime = modtime
			if ( status == false ) then
				print( ret )
			else
				s.sound = ret

				if ( game ) then
					game.call( "client", "onReloadSound", filename )
				else
					require( "engine.shared.hook" )
					hook.call( "client", "onReloadSound", filename )
				end
			end
		end
	end
end

function sound:sound( filename )
	local status, ret = pcall( require, filename )
	if ( status == false ) then
		self.filename = filename
	else
		local data    = ret
		self.filename = data[ "sound" ]
		self.volume   = data[ "volume" ]
	end
end

function sound:getFilename()
	return self.filename
end

function sound:getVolume()
	if ( self.volume ) then
		return self.volume
	end

	local filename = self:getFilename()
	if ( sounds[ filename ] ) then
		return sounds[ filename ]:getVolume()
	end

	return 1.0
end

function sound:setVolume( volume )
	self.volume = volume

	local filename = self:getFilename()
	if ( sounds[ filename ] ) then
		sounds[ filename ].sound:setVolume( volume )
	end
end

function sound:play()
	local filename = self:getFilename()
	if ( not filename ) then
		return
	end

	if ( not sounds[ filename ] ) then
		local sound = audio.newSource( filename )
		sounds[ filename ] = {
			sound   = sound,
			modtime = filesystem.getLastModified( filename )
		}

		local volume = self:getVolume()
		self:setVolume( volume )
	end

	audio.play( sounds[ filename ].sound )
end

function sound:__tostring()
	local t = getmetatable( self )
	setmetatable( self, {} )
	local s = string.gsub( tostring( self ), "table", "sound" )
	setmetatable( self, t )
	return s
end
