--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Default scheme
--
--============================================================================--

local default               = scheme( "Default" )

default.colors              = {
    gray                    = color( 104, 106, 107,        255 ),
    black                   = color(  31,  35,  36,        255 ),
    white                   = color( 204, 216, 219,        255 ),
    gold                    = color( 155, 140, 103,        255 )
}

default.button              = {
    backgroundColor         = color( default.colors.black, 0.27 * 255 ),
    outlineColor            = color( default.colors.gray,  0.42 * 255 ),
    textColor               = color( 163, 167, 168,        255 ),

    mouseover               = {
        backgroundColor     = color( default.colors.gold,  0.27 * 255 ),
        outlineColor        = color( default.colors.gold,  0.42 * 255 )
    },

    mousedown               = {
        backgroundColor     = color( default.colors.gold,  0.14 * 255 ),
        outlineColor        = color( default.colors.gold,  0.27 * 255 )
    },

    disabled                = {
        backgroundColor     = color( default.colors.black, 0.14 * 255 ),
        outlineColor        = color( default.colors.black, 0.14 * 255 ),
        textColor           = default.colors.gray
    }
}

default.checkbox            = {
    icon                    = graphics.newImage( "images/gui/check.png" ),
    iconColor               = color( 163, 167, 168,        255 ),
    outlineColor            = color( default.colors.gray,  0.66 * 255 ),
    textColor               = color( 163, 167, 168,        255 ),

    mouseover               = {
        outlineColor        = color( default.colors.gold,  0.42 * 255 )
    },

    mousedown               = {
        outlineColor        = color( default.colors.gold,  0.27 * 255 )
    },

    disabled                = {
        iconColor           = default.colors.gray,
        textColor           = default.colors.gray
    }
}

default.closebutton         = {
    icon                    = graphics.newImage( "images/gui/close.png" ),
    iconColor               = default.colors.white,

    mouseover               = {
        iconColor           = color( default.colors.gold,  255 )
    },

    mousedown               = {
        iconColor           = color( default.colors.gold,  0.66 * 255 )
    }
}

default.commandbutton       = {
    backgroundColor         = color(  67,  68,  69, 0.86 * 255 ),
    outlineColor            = color(  17,  18,  18, 0.14 * 255 )
}

default.commandbuttongroup  = {
    outlineColor            = color(  17,  18,  18, 0.14 * 255 )
}

default.dropdownlist        = {
    icon                    = graphics.newImage( "images/gui/arrow_down.png" ),
}

default.dropdownlistitem    = {
    backgroundColor         = color(  67,  68,  69, 0.97 * 255 ),
    outlineColor            = color( default.colors.gold,  0.97 * 255 ),

    mouseover               = {
        backgroundColor     = color( default.colors.gold,  0.97 * 255 ),
        textColor           = color( default.colors.black, 255 )
    },

    selected                = {
        backgroundColor     = color( default.colors.gold,  0.97 * 255 ),
        textColor           = color( default.colors.black, 255 )
    }
}

default.frame               = {
    backgroundColor         = color(  67,  68,  69, 0.97 * 255 ),
    outlineColor            = color( 240, 246, 247, 0.07 * 255 ),
    titleTextColor          = default.colors.white,

    defocus                 = {
        titleTextColor      = color( default.colors.white, 0.24 * 255 )
    }
}

default.frametab            = {
    backgroundColor         = color(  59,  61,  61, 0.93 * 255 ),
    outlineColor            = color(  17,  18,  18, 0.14 * 255 ),

    mouseover               = {
        backgroundColor     = color( default.colors.gold,  0.27 * 255 )
    },

    selected                = {
        backgroundColor     = default.frame.backgroundColor
    }
}

default.hudchat             = {
    backgroundColor         = color( default.colors.black, 0.27 * 255 ),
}

default.hudspeechballoons   = {
    backgroundColor         = color( default.colors.black, 0.66 * 255 ),
    outlineColor            = color( default.colors.black, 0.86 * 255 ),
    textColor               = default.colors.gold
}

default.hudmoveindicator    = {
    textColor               = default.colors.white,
    smallTextColor          = default.colors.gray,
 -- indicatorColor          = color( 157, 168,  57,        255 )
    indicatorColor          = default.colors.gold
}

default.label               = {
    textColor               = color( 163, 167, 168,        255 )
}

default.mainmenu            = {
    backgroundColor         = color( default.colors.black, 0.27 * 255 ),
    logo                    = graphics.newImage( "images/gui/logo.png" ),
    logoSmall               = graphics.newImage( "images/gui/logo_small.png" )
}

default.mainmenubutton      = {
    default                 = {
        textColor           = default.colors.gray,

        mouseover           = {
            textColor       = default.colors.gold
        },

        mousedown           = {
            textColor       = color( default.colors.gold,  0.66 * 255 )
        }
    },

    dark                    = {
        textColor           = default.colors.white,

        mouseover           = {
            textColor       = default.colors.gold
        },

        mousedown           = {
            textColor       = color( default.colors.gold,  0.66 * 255 )
        },

        disabled            = {
            textColor       = color(  67,  68,  69,        255 )
        }
    }
}

default.mainmenuclosebutton = {
    icon                    = graphics.newImage( "images/gui/close_large.png" ),

    default                 = {
        iconColor           = default.colors.gray,

        mouseover           = {
            iconColor       = default.colors.gold
        },

        mousedown           = {
            iconColor       = color( default.colors.gold,  0.66 * 255 )
        }
    },

    dark                    = {
        iconColor           = default.colors.white,

        mouseover           = {
            iconColor       = default.colors.gold
        },

        mousedown           = {
            iconColor       = color( default.colors.gold,  0.66 * 255 )
        }
    }
}

default.radiobutton         = {
    foreground              = graphics.newImage( "images/gui/radiobutton_foreground.png" ),
    icon                    = graphics.newImage( "images/gui/selection_dot.png" ),
    iconColor               = color( 163, 167, 168,        255 ),
    outlineColor            = color( default.colors.gray,  0.86 * 255 ),
    textColor               = color( 163, 167, 168,        255 ),

    mouseover               = {
        outlineColor        = color( default.colors.gold,  0.42 * 255 )
    },

    mousedown               = {
        outlineColor        = color( default.colors.gold,  0.27 * 255 )
    },

    disabled                = {
        iconColor           = default.colors.gray,
        textColor           = default.colors.gray
    }
}

default.scrollbar           = {
    backgroundColor         = color( default.colors.gold,  0.86 * 255 ),

    disabled                = {
        backgroundColor     = color( default.colors.black, 0.14 * 255 )
    }
}

default.textbox             = {
    outlineColor            = color( default.colors.gray,  0.66 * 255 ),
    textColor               = default.colors.gray,
    selectionColor          = color( default.colors.gold,  0.42 * 255 ),

    mouseover               = {
        outlineColor        = color( default.colors.gold,  0.42 * 255 ),
        textColor           = color( 163, 167, 168,        255 )
    },

    focus                   = {
        outlineColor        = color( default.colors.gold,  0.27 * 255 ),
        textColor           = color( 163, 167, 168,        255 )
    },

    disabled                = {
        textColor           = default.colors.gray
    }
}

default.bindlistpanel       = {
    backgroundColor         = color( default.colors.black, 0.66 * 255 ),
    outlineColor            = color( default.colors.gray,  0.66 * 255 )
}

default.bindlistheader      = {
    borderColor             = color(  15,  15,  15,        255 ),
}

default.mainmenuFont        = graphics.newFont( "fonts/SourceSansPro-Regular.otf", 24 )
default.titleFont           = graphics.newFont( "fonts/SourceSansPro-Bold.otf", 18 )
default.font                = graphics.newFont( "fonts/SourceSansPro-Regular.otf", 14 )
default.fontBold            = graphics.newFont( "fonts/SourceSansPro-Bold.otf", 14 )
default.consoleFont         = graphics.newFont( "fonts/SourceCodePro-Light.otf", 12 )
default.chatFont            = graphics.newFont( "fonts/SourceCodePro-Light.otf", 14 )
default.entityFont          = graphics.newFont( "fonts/SourceSansPro-Regular.otf", 24 )

if ( _AXIS ) then
default.axisUsernameFont    = graphics.newFont( "fonts/SourceSansPro-Light.otf", 18 )
end
