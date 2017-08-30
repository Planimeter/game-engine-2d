--=========== Copyright © 2017, Planimeter, All rights reserved. ===========--
--
-- Purpose: Console class
--
--==========================================================================--

require( "engine.client.gui.console.textbox" )
require( "engine.client.gui.console.textboxautocompleteitemgroup" )

class "gui.console" ( "gui.frame" )

local console = gui.console

function console.print( ... )
	local args = { ... }
	table.tostring( args )
	local output = g_Console.output
	local text   = table.concat( args, "\t" ) .. "\n"
	output:insertText( text )
end

local function doConCommand( command, argString, argTable )
	concommand.dispatch( localplayer, command, argString, argTable )
end

local function doConVar( command, argString )
	if ( argString ~= "" ) then
		local quoted = string.match( argString, "^\"(.-)\"$" )
		if ( quoted ) then
			argString = quoted
		end
		convar.setConvar( command, argString )
	else
		local convar     = convar.getConvar( command )
		local name       = convar:getName()
		local value      = convar:getValue()
		local helpString = convar:getHelpString() or ""
		local default    = convar:getDefault()    or ""
		if ( default ~= "" ) then
			default = "(Default: \"" .. default .. "\")\n"
		end
		print( name .. " = \"" .. value .. "\" " .. default .. helpString )
	end
end

local function doCommand( self, input )
	local textbox = self.input
	textbox:setText( "" )
	print( "] " .. input )

	local command = string.match( input, "^([^%s]+)" )
	if ( command == nil ) then
		return
	end

	local _, endPos = string.find( input, command, 1, true )
	local argString = string.trim( string.utf8sub( input, endPos + 1 ) )
	local argTable  = string.parseargs( argString )
	if ( concommand.getConcommand( command ) ) then
		doConCommand( command, argString, argTable )
	elseif ( convar.getConvar( command ) ) then
		doConVar( command, argString )
	else
		print( "'" .. command .. "' is not recognized as a console command " ..
		       "or variable." )
	end
end

console._commandHistory = console._commandHistory or {}

local function autocomplete( text )
	if ( text == "" ) then
		return nil
	end

	local history     = console._commandHistory
	local suggestions = {}

	for command in pairs( concommand._concommands ) do
		local match       = string.find( command, text, 1, true ) == 1
		local isInHistory = table.hasvalue( history, command )
		if ( match and not isInHistory ) then
			table.insert( suggestions, command .. " " )
		end
	end

	for command, convar in pairs( convar._convars ) do
		local match = string.find( command, text, 1, true ) == 1
		if ( match ) then
			table.insert( suggestions, command .. " " .. convar:getValue() )
		end
	end

	table.sort( suggestions )

	for _, history in ipairs( history ) do
		local match = string.find( history, text, 1, true ) == 1
		if ( match ) then
			table.insert( suggestions, 1, history )
		end
	end

	local name = string.match( text, "^([^%s]+)" )
	if ( name == nil ) then
		return
	end

	local command = concommand.getConcommand( name )
	local shouldAutocomplete = string.find( text, name .. " ", 1, true )
	if ( command and shouldAutocomplete ) then
		local _, endPos    = string.find( text, name, 1, true )
		local argS         = string.trim( string.utf8sub( text, endPos + 1 ) )
		local argT         = string.parseargs( argS )
		local autocomplete = command:getAutocomplete( argS, argT )
		if ( autocomplete ) then
			local t = autocomplete( argS, argT )
			if ( t ) then
				table.prepend( suggestions, t )
			end
		end
	end

	suggestions = table.unique( suggestions )
	return #suggestions > 0 and suggestions or nil
end

local keypressed = function( itemGroup, key, isrepeat )
	if ( key ~= "delete" ) then
		return
	end

	-- BUGBUG: We never get here anymore due to the introduction of
	-- cascadeInputToChildren.
	local history = console._commandHistory
	for i, v in ipairs( history ) do
		if ( itemGroup:getValue() == v ) then
			table.remove( history, i )
			local item = itemGroup:getSelectedItem()
			itemGroup:removeItem( item )
			return
		end
	end
end

function console:console( parent, name, title )
	parent = parent or g_MainMenu
	name   = name or "Console"
	title  = title or name
	gui.frame.frame( self, parent, name, title )
	self.width     = love.window.toPixels( 661 )
	self.minHeight = love.window.toPixels( 178 )

	self.output = console.textbox( self, name .. " Output Text Box", "" )
	self.input  = gui.textbox( self, name .. " Input Text Box", "" )
	self.input.onEnter = function( textbox, text )
		text = string.trim( text )
		doCommand( self, text )

		if ( text == "" ) then
			return
		end

		local history = console._commandHistory
		if ( not table.hasvalue( history, text ) ) then
			table.insert( history, text )
		end
	end

	local input = self.input
	input:setAutocomplete( autocomplete )
	name = name .. " Autocomplete Item Group"
	local autocompleteItemGroup = console.textboxautocompleteitemgroup
	input.autocompleteItemGroup = autocompleteItemGroup( self.input, name )
	input.autocompleteItemGroup.keypressed = keypressed

	self:invalidateLayout()
end

function console:activate()
	self:invalidate()
	gui.frame.activate( self )
	gui.setFocusedPanel( self.input, true )
end

function console:invalidateLayout()
	local parent = self:getParent()
	local margin = gui.scale( 36 )
	local width  = self:getWidth()
	local height = self:getHeight()
	local x      = parent:getWidth() - margin - width
	local y      = margin
	if ( not self:isResizing() ) then
		self:setPos( x, y )
	end

	local output = self.output
	margin       = love.window.toPixels( 36 )
	x            = margin
	y            = love.window.toPixels( 86 ) -- Title Bar Height
	width        = width - 2 * margin
	output:setPos( x, y )
	output:setWidth( width )

	local input  = self.input
	y            = height - margin - input:getHeight()
	input:setPos( x, y )
	input:setWidth( width )

	gui.frame.invalidateLayout( self )
end

local con_enable = convar( "con_enable", "0", nil, nil,
                           "Allows the console to be activated" )

concommand( "toggleconsole", "Show/hide the console", function()
	local console = g_Console
	if ( con_enable:getBoolean() ) then
		local mainmenu = g_MainMenu
		if ( not mainmenu:isVisible() ) then
			mainmenu:activate()
			console:activate()
			return
		end
	end

	if ( console:isVisible() ) then
		console:close()
		return
	end

	if ( not con_enable:getBoolean() ) then
		return
	end

	console:activate()
end )

concommand( "clear", "Clears the console", function()
	if ( love.system.getOS() == "Windows" ) then
		-- This breaks the LOVE console. :(
		-- os.execute( "cls" )
	else
		os.execute( "clear" )
	end

	if ( g_Console ) then
		local output = g_Console.output
		output:setText( "" )
	end
end )

concommand( "echo", "Echos text to console",
	function( _, _, _, argS, argT )
		print( argS )
	end
)

concommand( "help", "Prints help info for the console command or variable",
	function( _, _, _, _, argT )
		local name = argT[ 1 ]
		if ( name == nil ) then
			print( "help <console command or variable name>" )
			return
		end

		local command = concommand.getConcommand( name ) or
		                convar.getConvar( name )
		if ( command ) then
			print( command:getHelpString() )
		else
			print( "'" .. name .. "' is not a valid console command or " ..
			       "variable." )
		end
	end
)

local function restorePanel()
	local console = g_Console
	if ( console == nil ) then
		return
	end

	local visible = console:isVisible()
	local output  = console.output
	local text    = output:getText()
	console:remove()
	console   = gui.console( g_MainMenu )
	g_Console = console
	output    = console.output
	output:setText( text )
	if ( visible ) then
		console:activate()
	end
end

restorePanel()
