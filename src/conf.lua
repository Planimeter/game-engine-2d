--========= Copyright © 2013-2014, Planimeter, All rights reserved. ==========--
--
-- Purpose:
--
--============================================================================--

local function loadConfig( c )
    love.filesystem.setIdentity( c.identity, c.appendidentity )

    require( "class" )
    require( "engine.shared.filesystem" )
    require( "engine.shared.convar" )
    convar.readConfig()

    local r_window_width      = convar.getConfig( "r_window_width" )
    local r_window_height     = convar.getConfig( "r_window_height" )
    local r_window_fullscreen = convar.getConfig( "r_window_fullscreen" )
    local r_window_borderless = convar.getConfig( "r_window_borderless" )
    local r_window_vsync      = convar.getConfig( "r_window_vsync" )
    if ( r_window_width ) then
        c.window.width        = tonumber( r_window_width )
    end
    if ( r_window_height ) then
        c.window.height       = tonumber( r_window_height )
    end
    if ( r_window_fullscreen ) then
        c.window.fullscreen   = tonumber( r_window_fullscreen ) ~= nil and
                                tonumber( r_window_fullscreen ) ~= 0
    end
    if ( r_window_borderless ) then
        c.window.borderless   = tonumber( r_window_borderless ) ~= nil and
                                tonumber( r_window_borderless ) ~= 0
    end
    if ( r_window_vsync ) then
        c.window.vsync        = tonumber( r_window_vsync ) ~= nil and
                                tonumber( r_window_vsync ) ~= 0
    end

    _CONF = c
end

function love.conf( c )

        c.title = "Grid Engine"
        c.author = "Planimeter"
        for i, v in ipairs( arg ) do
            if ( v == "-dedicated" ) then
                c.modules.keyboard = false
                c.modules.mouse = false
                c.modules.joystick = false
                c.modules.graphics = false
                c.modules.audio = false
                c.modules.sounds = false
                c.modules.system = false
                c.modules.font = false
                c.modules.window = false
                c.console = true -- Only relevant for windows.
            end

            if ( v == "-debug" ) then
                -- c.console = true -- Only relevant for windows.
            end
        end
        c.identity = "grid"
        c.apppendidentity = true

        loadConfig( c )
        c.window.icon = "images/icon.png"

        return c

end
