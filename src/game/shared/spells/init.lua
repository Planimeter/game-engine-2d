--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: spell
--
--============================================================================--

-- These values are preserved during real-time scripting.
local spells = spell and spell.spells or {}

class "spell"

spell.spells = spells

function spell.invoke()
	return
end

function spell:spell()
end

function spell:draw()
end

function spell:update( dt )
end
