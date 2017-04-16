--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Sound class
--
--============================================================================--

local function updateVolume( convar )
	local volume = convar:getNumber()
	love.audio.setVolume( volume )
end

convar( "snd_volume", 1, 0, 1,
        "Sets the master volume",
        updateVolume )
convar( "snd_desktop", "1", nil, nil,
        "Toggles playing sound from the desktop" )
