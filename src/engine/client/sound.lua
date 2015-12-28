--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Sound class
--
--============================================================================--

-- These values are preserved during real-time scripting.
local sounds = sound and sound.sounds or {}

local audio = love.audio

class( "sound" )

function sound.reload( library )
	if ( string.sub( library, 1, 7 ) ~= "sounds." ) then
		return
	end

	-- TODO: Reload soundscript.
end

hook.set( "shared", sound.reload, "onReloadScript", "reloadSound" )

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
		self.data     = ret
		self.filename = self.data[ "sound" ]
	end
end

function sound:getData()
	return self.data
end

function sound:getFilename()
	return self.filename
end

function sound:getVolume()
	local filename = self:getFilename()
	if ( sounds[ filename ] ) then
		return sounds[ filename ].sound:getVolume()
	end
end

function sound:setVolume( volume )
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

		local data = self:getData()
		if ( data ) then
			local volume = data[ "volume" ]
			if ( volume ) then
				self:setVolume( volume )
			end
		end
	end

	local sound = sounds[ filename ].sound
	if ( sound:isPlaying() ) then
		sound = sound:clone()
		sound:rewind()
	end

	audio.play( sound )
end

function sound:__tostring()
	local t = getmetatable( self )
	setmetatable( self, {} )
	local s = string.gsub( tostring( self ), "table", "sound" )
	setmetatable( self, t )
	return s
end
