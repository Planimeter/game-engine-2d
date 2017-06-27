--=========== Copyright © 2017, Planimeter, All rights reserved. ===========--
--
-- Purpose: Sound class
--
--==========================================================================--

class( "sound" )

sound._sounds = sound._sounds or {}

local function copy( k )
	if ( string.find( k, "__" ) == 1 ) then
		return
	end

	sound[ k ] = function( self, ... )
		local filename = self:getFilename()
		local sound = sound._sounds[ filename ]
		if ( not sound ) then
			return
		end

		local self = sound.sound
		return self[ k ]( self, ... )
	end
end

local _R = debug.getregistry()
for k in pairs( _R.Source ) do
	copy( k )
end

local function reload( filename )
	print( "Updating " .. filename .. "..." )

	local status, ret = pcall( love.audio.newSource, filename )
	if ( status == true ) then
		local modtime, errormsg = love.filesystem.getLastModified( filename )
		sound._sounds[ filename ].sound   = ret
		sound._sounds[ filename ].modtime = modtime

		if ( game ) then
			game.call( "client", "onReloadSound", filename )
		else
			require( "engine.shared.hook" )
			hook.call( "client", "onReloadSound", filename )
		end
	else
		print( ret )
	end
end

function sound.update( dt )
	for k, v in pairs( sound._sounds ) do
		local modtime, errormsg = love.filesystem.getLastModified( k )
		if ( not errormsg and modtime ~= v.modtime ) then
			reload( k )
		end
	end
end

function sound.reload( library )
	if ( string.sub( library, 1, 7 ) ~= "sounds." ) then
		return
	end
	-- TODO: Reload soundscript.
end

hook.set( "client", sound.reload, "onReloadScript", "reloadSound" )

function sound:sound( filename )
	local status, ret = pcall( require, filename )
	if ( status == true ) then
		self.data     = ret
		self.filename = self.data[ "sound" ]
	else
		self.filename = filename
	end
end

accessor( sound, "data" )
accessor( sound, "filename" )

function sound:parse()
	local filename = self:getFilename()
	sound._sounds[ filename ] = {
		sound   = love.audio.newSource( filename ),
		modtime = love.filesystem.getLastModified( filename )
	}

	local data = self:getData()
	if ( not data ) then
		return
	end

	local volume = data[ "volume" ]
	if ( volume ) then
		self:setVolume( volume )
	end
end

function sound:play()
	local filename = self:getFilename()
	if ( not sound._sounds[ filename ] ) then
		self:parse()
	end

	local sound = sound._sounds[ filename ].sound
	if ( sound:isPlaying() ) then
		sound = sound:clone()
		sound:rewind()
	end

	love.audio.play( sound )
end

function sound:__tostring()
	local t = getmetatable( self )
	setmetatable( self, {} )
	local s = string.gsub( tostring( self ), "table", "sound" )
	setmetatable( self, t )
	return s
end
