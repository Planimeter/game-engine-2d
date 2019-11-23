--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Chat HUD scheme
--
--==========================================================================--

local chat          = scheme( "Chat" )

chat.textbox        = {
    backgroundColor = color(   0,   0,  0,  0    * 255 ),
    borderColor     = color( 104, 106, 107, 0.66 * 255 ),
    textColor       = color( 230, 230, 230,        255 ),

    mouseover       = {
        borderColor = color( 163, 126,  71, 0.42 * 255 ),
        textColor   = color( 163, 167, 168,        255 )
    },

    focus           = {
        borderColor = color( 163, 126,  71, 0.27 * 255 ),
        textColor   = color( 163, 167, 168,        255 )
    }
}

-- NOTE: The following arguments to `newFont` are undocumented.
local dpiscale = love.graphics.getDPIScale()
local r_window_highdpi = convar.getConvar( "r_window_highdpi" )
if ( r_window_highdpi:getNumber() == 2 ) then
    dpiscale = 1
end

chat.font           = love.graphics.newFont(
    "fonts/SourceSansPro-Regular.otf", 14, "normal", dpiscale
)
