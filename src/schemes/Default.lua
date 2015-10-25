--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Default scheme
--
--============================================================================--

local t                       = scheme( "Default" )

t.colors                      = {
    gray                      = color( 104, 106, 107,         255 ),
    black                     = color(  31,  35,  36,         255 ),
    white                     = color( 204, 216, 219,         255 ),
    gold                      = color( 155, 140, 103,         255 )
}

t.button                      = {
    backgroundColor           = color( t.colors.black, 0.27 * 255 ),
    outlineColor              = color( t.colors.gray,  0.42 * 255 ),
    textColor                 = color( 163, 167, 168,         255 ),

    mouseover                 = {
        backgroundColor       = color( t.colors.gold,  0.27 * 255 ),
        outlineColor          = color( t.colors.gold,  0.42 * 255 )
    },

    mousedown                 = {
        backgroundColor       = color( t.colors.gold,  0.14 * 255 ),
        outlineColor          = color( t.colors.gold,  0.27 * 255 )
    },

    disabled                  = {
        backgroundColor       = color( t.colors.black, 0.14 * 255 ),
        outlineColor          = color( t.colors.black, 0.14 * 255 ),
        textColor             = t.colors.gray
    }
}

t.checkbox                    = {
    icon                      = graphics.newImage( "images/gui/check.png" ),
    iconColor                 = color( 163, 167, 168,         255 ),
    outlineColor              = color( t.colors.gray,  0.66 * 255 ),
    textColor                 = color( 163, 167, 168,         255 ),

    mouseover                 = {
        outlineColor          = color( t.colors.gold,  0.42 * 255 )
    },

    mousedown                 = {
        outlineColor          = color( t.colors.gold,  0.27 * 255 )
    },

    disabled                  = {
        iconColor             = t.colors.gray,
        textColor             = t.colors.gray
    }
}

t.closebutton                 = {
    icon                      = graphics.newImage( "images/gui/close.png" ),
    iconColor                 = t.colors.white,

    mouseover                 = {
        iconColor             = color( t.colors.gold,          255 )
    },

    mousedown                 = {
        iconColor             = color( t.colors.gold,   0.66 * 255 )
    }
}

t.commandbutton               = {
    backgroundColor           = color(  67,  68,  69,   0.86 * 255 ),
    outlineColor              = color(  17,  18,  18,   0.14 * 255 )
}

t.commandbuttongroup          = {
    outlineColor              = color(  17,  18,  18,   0.14 * 255 )
}

t.dropdownlist                = {
    icon                      = graphics.newImage( "images/gui/arrow_down.png" ),
}

t.dropdownlistitem            = {
    backgroundColor           = color(  67,  68,  69,   0.97 * 255 ),
    outlineColor              = color( t.colors.gold,   0.97 * 255 ),

    mouseover                 = {
        backgroundColor       = color( t.colors.gold,   0.97 * 255 ),
        textColor             = color( t.colors.black,         255 )
    },

    selected                  = {
        backgroundColor       = color( t.colors.gold,   0.97 * 255 ),
        textColor             = color( t.colors.black,         255 )
    }
}

t.frame                       = {
    backgroundColor           = color(  67,  68,  69,   0.97 * 255 ),
    outlineColor              = color( 240, 246, 247,   0.07 * 255 ),
    titleTextColor            = t.colors.white,

    defocus                   = {
        titleTextColor        = color( t.colors.white,  0.24 * 255 )
    }
}

t.frametab                    = {
    backgroundColor           = color(  59,  61,  61,   0.93 * 255 ),
    outlineColor              = color(  17,  18,  18,   0.14 * 255 ),

    mouseover                 = {
        backgroundColor       = color( t.colors.gold,   0.27 * 255 )
    },

    selected                  = {
        backgroundColor       = t.frame.backgroundColor
    }
}

t.hudchat                     = {
    backgroundColor           = color( t.colors.black,  0.27 * 255 )
}

t.hudgamemenu                 = {
    backgroundColor           = color( t.colors.black,  0.27 * 255 )
}

t.hudgamemenunavigation       = {
    backgroundColor           = color( t.colors.white,  0.07 * 255 )
}

t.hudgamemenunavigationbutton = {
    borderColor               = t.colors.gold,
    textColor                 = color( t.colors.white, 0.42 * 255 ),

    mouseover                 = {
        textColor             = color( t.colors.gold,  0.42 * 255 )
    }
}

t.hudspeechballoons           = {
    textColor                 = t.colors.gold
}

t.hudmoveindicator            = {
    textColor                 = t.colors.white,
    smallTextColor            = t.colors.gray,
 -- indicatorColor            = color( 157, 168,  57,         255 )
    indicatorColor            = t.colors.gold
}

t.label                       = {
    textColor                 = color( 163, 167, 168,         255 )
}

t.mainmenu                    = {
    backgroundColor           = color( t.colors.black, 0.27 * 255 ),
    logo                      = graphics.newImage( "images/gui/logo.png" ),
    logoSmall                 = graphics.newImage( "images/gui/logo_small.png" )
}

t.mainmenubutton              = {
    t                         = {
        textColor             = t.colors.gray,

        mouseover             = {
            textColor         = t.colors.gold
        },

        mousedown             = {
            textColor         = color( t.colors.gold,  0.66 * 255 )
        }
    },

    dark                      = {
        textColor             = t.colors.white,

        mouseover             = {
            textColor         = t.colors.gold
        },

        mousedown             = {
            textColor         = color( t.colors.gold,  0.66 * 255 )
        },

        disabled              = {
            textColor         = color(  67,  68,  69,         255 )
        }
    }
}

t.mainmenuclosebutton         = {
    icon                      = graphics.newImage( "images/gui/close_large.png" ),

    t                         = {
        iconColor             = t.colors.gray,

        mouseover             = {
            iconColor         = t.colors.gold
        },

        mousedown             = {
            iconColor         = color( t.colors.gold,  0.66 * 255 )
        }
    },

    dark                      = {
        iconColor             = t.colors.white,

        mouseover             = {
            iconColor         = t.colors.gold
        },

        mousedown             = {
            iconColor         = color( t.colors.gold,  0.66 * 255 )
        }
    }
}

t.radiobutton                 = {
    foreground                = graphics.newImage( "images/gui/radiobutton_foreground.png" ),
    icon                      = graphics.newImage( "images/gui/selection_dot.png" ),
    iconColor                 = color( 163, 167, 168,         255 ),
    outlineColor              = color( t.colors.gray,  0.86 * 255 ),
    textColor                 = color( 163, 167, 168,         255 ),

    mouseover                 = {
        outlineColor          = color( t.colors.gold,  0.42 * 255 )
    },

    mousedown                 = {
        outlineColor          = color( t.colors.gold,  0.27 * 255 )
    },

    disabled                  = {
        iconColor             = t.colors.gray,
        textColor             = t.colors.gray
    }
}

t.scrollbar                   = {
    backgroundColor           = color( t.colors.gold,  0.86 * 255 ),

    disabled                  = {
        backgroundColor       = color( t.colors.black, 0.14 * 255 )
    }
}

t.textbox                     = {
    outlineColor              = color( t.colors.gray,  0.66 * 255 ),
    textColor                 = t.colors.gray,
    selectionColor            = color( t.colors.gold,  0.42 * 255 ),

    mouseover                 = {
        outlineColor          = color( t.colors.gold,  0.42 * 255 ),
        textColor             = color( 163, 167, 168,         255 )
    },

    focus                     = {
        outlineColor          = color( t.colors.gold,  0.27 * 255 ),
        textColor             = color( 163, 167, 168,         255 )
    },

    disabled                  = {
        textColor             = t.colors.gray
    }
}

t.bindlistpanel               = {
    backgroundColor           = color( t.colors.black, 0.66 * 255 ),
    outlineColor              = color( t.colors.gray,  0.66 * 255 )
}

t.bindlistheader              = {
    borderColor               = color(  15,  15,  15,         255 ),
}

t.mainmenuFont                = graphics.newFont( "fonts/SourceSansPro-Regular.otf", 24 )
t.titleFont                   = graphics.newFont( "fonts/SourceSansPro-Bold.otf", 18 )
t.font                        = graphics.newFont( "fonts/SourceSansPro-Regular.otf", 14 )
t.fontBold                    = graphics.newFont( "fonts/SourceSansPro-Bold.otf", 14 )
t.consoleFont                 = graphics.newFont( "fonts/SourceCodePro-Light.otf", 12 )
t.chatFont                    = graphics.newFont( "fonts/SourceCodePro-Light.otf", 14 )
t.entityFont                  = graphics.newFont( "fonts/SourceSansPro-Regular.otf", 24 )

if ( _AXIS ) then
t.axisUsernameFont            = graphics.newFont( "fonts/SourceSansPro-Light.otf", 18 )
end
