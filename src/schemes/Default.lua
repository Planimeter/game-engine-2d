--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Default scheme
--
--============================================================================--

local default               = scheme( "Default" )

default.button              = {
    backgroundColor         = color(  35,  35,  36, 0.27 * 255 ),
    outlineColor            = color( 104, 106, 107, 0.42 * 255 ),
    textColor               = color( 163, 167, 168,        255 ),

    mouseover               = {
        backgroundColor     = color( 163, 126,  71, 0.27 * 255 ),
        outlineColor        = color( 163, 126,  71, 0.42 * 255 )
    },

    mousedown               = {
        backgroundColor     = color( 163, 126,  71, 0.14 * 255 ),
        outlineColor        = color( 163, 126,  71, 0.27 * 255 )
    },

    disabled                = {
        backgroundColor     = color(  35,  35,  36, 0.14 * 255 ),
        outlineColor        = color(  35,  35,  36, 0.14 * 255 ),
        textColor           = color( 104, 106, 107,        255 )
    }
}

default.checkbox            = {
    icon                    = graphics.newImage( "images/gui/check.png" ),
    iconColor               = color( 163, 167, 168,        255 ),
    outlineColor            = color( 104, 106, 107, 0.66 * 255 ),
    textColor               = color( 163, 167, 168,        255 ),

    mouseover               = {
        outlineColor        = color( 163, 126,  71, 0.42 * 255 )
    },

    mousedown               = {
        outlineColor        = color( 163, 126,  71, 0.27 * 255 )
    },

    disabled                = {
        iconColor           = color( 104, 106, 107,        255 ),
        textColor           = color( 104, 106, 107,        255 )
    }
}

default.closebutton         = {
    icon                    = graphics.newImage( "images/gui/close.png" ),
    iconColor               = color( 213, 218, 219,        255 ),

    mouseover               = {
        iconColor           = color( 163, 126,  71,        255 )
    },

    mousedown               = {
        iconColor           = color( 163, 126,  71, 0.66 * 255 )
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
    outlineColor            = color( 163, 126,  71, 0.97 * 255 ),

    mouseover               = {
        backgroundColor     = color( 163, 126,  71, 0.97 * 255 ),
        textColor           = color(  35,  35,  36,       255 )
    },

    selected                = {
        backgroundColor     = color( 163, 126,  71, 0.97 * 255 ),
        textColor           = color(  35,  35,  36,       255 )
    }
}

default.frame               = {
    backgroundColor         = color(  67,  68,  69, 0.97 * 255 ),
    outlineColor            = color( 240, 246, 247, 0.07 * 255 ),
    titleTextColor          = color( 213, 218, 219,       255 ),

    defocus                 = {
        titleTextColor      = color( 213, 218, 219, 0.24 * 255 )
    }
}

default.frametab            = {
    backgroundColor         = color(  59,  61,  61, 0.93 * 255 ),
    outlineColor            = color(  17,  18,  18, 0.14 * 255 ),

    mouseover               = {
        backgroundColor     = color( 163, 126,  71, 0.27 * 255 )
    },

    selected                = {
        backgroundColor     = default.frame.backgroundColor
    }
}

default.hudchat             = {
    backgroundColor         = color(  31,  35,  36, 0.27 * 255 ),
}

default.label               = {
    textColor               = color( 163, 167, 168,       255 )
}

default.mainmenu            = {
    logo                    = graphics.newImage( "images/gui/logo.png" ),
    logoSmall               = graphics.newImage( "images/gui/logo_small.png" )
}

default.mainmenubutton      = {
    default                 = {
        textColor           = color( 104, 106, 107,       255 ),

        mouseover           = {
            textColor       = color( 163, 126,  71,       255 )
        },

        mousedown           = {
            textColor       = color( 163, 126,  71, 0.66 * 255 )
        }
    },

    dark                    = {
        textColor           = color( 213, 218, 219,       255 ),

        mouseover           = {
            textColor       = color( 163, 126,  71,       255 )
        },

        mousedown           = {
            textColor       = color( 163, 126,  71, 0.66 * 255 )
        },

        disabled            = {
            textColor       = color(  67,  68,  69,       255 )
        }
    }
}

default.mainmenuclosebutton = {
    icon                    = graphics.newImage( "images/gui/close_large.png" ),

    default                 = {
        iconColor           = color( 104, 106, 107,       255 ),

        mouseover           = {
            iconColor       = color( 163, 126,  71,       255 )
        },

        mousedown           = {
            iconColor       = color( 163, 126,  71, 0.66 * 255 )
        }
    },

    dark                    = {
        iconColor           = color( 213, 218, 219,       255 ),

        mouseover           = {
            iconColor       = color( 163, 126,  71,       255 )
        },

        mousedown           = {
            iconColor       = color( 163, 126,  71, 0.66 * 255 )
        }
    }
}

default.radiobutton         = {
    foreground              = graphics.newImage( "images/gui/radiobutton_foreground.png" ),
    icon                    = graphics.newImage( "images/gui/selection_dot.png" ),
    iconColor               = color( 163, 167, 168,        255 ),
    outlineColor            = color( 104, 106, 107, 0.86 * 255 ),
    textColor               = color( 163, 167, 168,        255 ),

    mouseover               = {
        outlineColor        = color( 163, 126,  71, 0.42 * 255 )
    },

    mousedown               = {
        outlineColor        = color( 163, 126,  71, 0.27 * 255 )
    },

    disabled                = {
        iconColor           = color( 104, 106, 107,       255 ),
        textColor           = color( 104, 106, 107,       255 )
    }
}

default.scrollbar           = {
    backgroundColor         = color( 163, 127,  71, 0.86 * 255 ),

    disabled                = {
        backgroundColor     = color(  35,  35,  36, 0.14 * 255 )
    }
}

default.textbox             = {
    outlineColor            = color( 104, 106, 107, 0.66 * 255 ),
    textColor               = color( 104, 106, 107,        255 ),

    mouseover               = {
        outlineColor        = color( 163, 126,  71, 0.42 * 255 ),
        textColor           = color( 163, 167, 168,        255 )
    },

    focus                   = {
        outlineColor        = color( 163, 126,  71, 0.27 * 255 ),
        textColor           = color( 163, 167, 168,        255 )
    },

    disabled                = {
        textColor           = color( 104, 106, 107,        255 )
    }
}

default.bindlistpanel       = {
    backgroundColor         = color(  35,  35,  36, 0.66 * 255 ),
    outlineColor            = color( 104, 106, 107, 0.66 * 255 )
}

default.bindlistheader      = {
    borderColor             = color(  15,  15,  15,        255 ),
}

default.mainmenuFont        = graphics.newFont( "fonts/SourceSansPro-Regular.otf", 24 )
default.titleFont           = graphics.newFont( "fonts/SourceSansPro-Bold.otf", 18 )
default.font                = graphics.newFont( "fonts/SourceSansPro-Regular.otf", 14 )
default.consoleFont         = graphics.newFont( "fonts/SourceCodePro-Light.otf", 12 )

if ( _AXIS ) then
default.axisUsernameFont    = graphics.newFont( "fonts/SourceSansPro-Light.otf", 18 )
end
