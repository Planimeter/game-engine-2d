--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: spell
--
--============================================================================--

-- These values are preserved during real-time scripting.
local spells = spell and spell.spells or {}

class "spell"

spell.spells = spells

spell.name = "Unknown Spell"

function spell.getSpell( name )
	return spell.spells[ name ]
end

function spell.invoke()
end

function spell.register( class, name )
	spell.spells[ name ] = class
	getfenv( 2 )[ name ] = nil
end

function spell:spell()
end

function spell:draw()
end

function spell:update( dt )
end
