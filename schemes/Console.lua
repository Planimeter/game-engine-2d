--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Console scheme
--
--============================================================================--

local console        = scheme( "Console" )

console.textbox      = {
    backgroundColor  = color(  35,  35,  36, 0.66 * 255 ),
    outlineColor     = color( 104, 106, 107, 0.66 * 255 ),
    textColor        = color( 104, 106, 107,        255 ),

    mouseover        = {
        outlineColor = color( 163, 126,  71, 0.42 * 255 ),
        textColor    = color( 163, 167, 168,        255 )
    },

    focus            = {
        outlineColor = color( 163, 126,  71, 0.27 * 255 ),
        textColor    = color( 163, 167, 168,        255 )
    }
}

console.font         = graphics.newFont( "fonts/SourceCodePro-Light.otf", 12 )
