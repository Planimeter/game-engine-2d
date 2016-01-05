--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
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

    local _INTERACTIVE        = c.args[ "-dedicated" ] and
                                c.args[ "-interactive" ]

    local r_window_width      = convar.getConfig( "r_window_width" )
    local r_window_height     = convar.getConfig( "r_window_height" )
    local r_window_fullscreen = convar.getConfig( "r_window_fullscreen" )
    local r_window_borderless = convar.getConfig( "r_window_borderless" )
    local r_window_vsync      = convar.getConfig( "r_window_vsync" )
    if ( _INTERACTIVE ) then
        c.window.width        = 661
    elseif ( r_window_width ) then
        c.window.width        = tonumber( r_window_width )
    end
    if ( _INTERACTIVE ) then
        c.window.height       = 480
    elseif ( r_window_height ) then
        c.window.height       = tonumber( r_window_height )
    end
    if ( r_window_fullscreen ) then
        c.window.fullscreen   = tonumber( r_window_fullscreen ) ~= nil and
                                tonumber( r_window_fullscreen ) ~= 0
    end
    if ( _INTERACTIVE ) then
        -- c.window.borderless   = true
    elseif ( r_window_borderless ) then
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

        c.args = {}
        for _, v in ipairs( arg ) do
            c.args[ v ] = true
        end

        if ( c.args[ "-dedicated" ] ) then
            c.modules.joystick = false
            c.modules.audio = false
            c.modules.sound = false
            c.modules.video = false

            if ( not c.args[ "-interactive" ] ) then
                c.modules.keyboard = false
                c.modules.mouse = false
                c.modules.touch = false
                c.modules.graphics = false
                c.modules.font = false
                c.modules.window = false
            else
                c.window.resizable = true
                c.window.centered = false
            end
            c.console = true -- Only relevant for windows.
        end

        if ( c.args[ "-debug" ] ) then
            c.console = true -- Only relevant for windows.
        end

        c.identity = "grid"
        c.apppendidentity = true

        loadConfig( c )
        c.window.icon = "images/icon.png"

        return c

end
