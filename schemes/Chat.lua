--=========== Copyright © 2017, Planimeter, All rights reserved. ===========--
--
-- Purpose: Chat HUD scheme
--
--==========================================================================--

local chat           = scheme( "Chat" )

chat.textbox         = {
    backgroundColor  = color(   0,   0,  0,  0    * 255 ),
    outlineColor     = color( 104, 106, 107, 0.66 * 255 ),
    textColor        = color( 230, 230, 230,        255 ),

    mouseover        = {
        outlineColor = color( 163, 126,  71, 0.42 * 255 ),
        textColor    = color( 163, 167, 168,        255 )
    },

    focus            = {
        outlineColor = color( 163, 126,  71, 0.27 * 255 ),
        textColor    = color( 163, 167, 168,        255 )
    }
}

chat.font            = love.graphics.newFont( "fonts/SourceSansPro-Regular.otf", 14 )
