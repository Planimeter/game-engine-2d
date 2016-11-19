--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Sound class
--
--============================================================================--

local accessor = accessor
local audio    = love.audio
local convar   = convar
local hook     = hook
local type     = type

module( "sound", package.class )

local function updateVolume( convar )
	local volume = convar:getNumber()
	setVolume( volume )
end

local snd_volume  = convar( "snd_volume", 1, 0, 1,
                            "Sets the master volume",
                            updateVolume )
local snd_desktop = convar( "snd_desktop", "1", nil, nil,
                            "Toggles playing sound from the desktop" )

function reload( library )
	if ( string.sub( library, 1, 7 ) ~= "sounds." ) then
		return
	end

	-- TODO: Reload soundscript.
end

hook.set( "shared", reload, "onReloadScript", "reloadSound" )

sounds = sounds or {}

local modtime  = nil
local errormsg = nil

local function updateSound( s, filename )
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
			hook.call( "client", "onReloadSound", filename )
		end
	end
end

function update( dt )
	for filename, s in pairs( sounds ) do
		modtime, errormsg = love.filesystem.getLastModified( filename )
		if ( errormsg == nil and modtime ~= s.modtime ) then
			updateSound( s, filename )
		end
	end
end

function _M:sound( filename )
	local status, ret = pcall( require, filename )
	if ( status == false ) then
		self.filename = filename
	else
		self.data     = ret
		self.filename = self.data[ "sound" ]
	end
end

function _M:getData()
	return self.data
end

accessor( _M, "filename" )

function _M:getVolume()
	local filename = self:getFilename()
	if ( sounds[ filename ] ) then
		return sounds[ filename ].sound:getVolume()
	end
end

function _M:setVolume( volume )
	if ( type( self ) == "number" ) then
		audio.setVolume( self ) -- volume
		return
	end

	local filename = self:getFilename()
	if ( sounds[ filename ] ) then
		sounds[ filename ].sound:setVolume( volume )
	end
end

function _M:play()
	local filename = self:getFilename()
	if ( not filename ) then
		return
	end

	if ( not sounds[ filename ] ) then
		local sound = audio.newSource( filename )
		sounds[ filename ] = {
			sound   = sound,
			modtime = love.filesystem.getLastModified( filename )
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

function _M:__tostring()
	local t = getmetatable( self )
	setmetatable( self, {} )
	local s = string.gsub( tostring( self ), "table", "sound" )
	setmetatable( self, t )
	return s
end
