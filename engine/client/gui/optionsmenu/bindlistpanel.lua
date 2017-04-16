--=========== Copyright © 2016, Planimeter, All rights reserved. =============--
--
-- Purpose: Bind List Panel class
--
--============================================================================--

require( "engine.client.gui.optionsmenu.bindlistheader" )
require( "engine.client.gui.optionsmenu.bindlistitem" )

class "gui.bindlistpanel" ( "gui.scrollablepanel" )

local bindlistpanel = gui.bindlistpanel

function bindlistpanel:bindlistpanel( parent, name )
	gui.scrollablepanel.scrollablepanel( self, parent, name )
	self.changedBinds = {}
end

function bindlistpanel:draw()
	self:drawBackground( "bindlistpanel.backgroundColor" )
	gui.panel.draw( self )
	self:drawForeground( "bindlistpanel.outlineColor" )
end

local function getLastY( self )
	local children = self:getChildren()
	if ( children ) then
		local y = 0
		for _, panel in ipairs( children ) do
			y = y + panel:getHeight()
		end
		return y
	end
	return 0
end

function bindlistpanel:addHeader( label )
	local panel = self:getInnerPanel()
	local name  = label .. " Bind List Header"
	local y     = getLastY( panel )
	local label = gui.bindlistheader( panel, name, label )
	label:setY( y )
	self:setInnerHeight( getLastY( panel ) )
end

function bindlistpanel:addBinding( text, key, concommand )
	local panel   = self:getInnerPanel()
	local name    = text .. " Bind List Item"
	local y       = getLastY( panel )
	local binding = gui.bindlistitem( panel, name, text, key, concommand )
	binding:setY( y )
	self:setInnerHeight( getLastY( panel ) )
end

function bindlistpanel:onBindChange( item, key, oldKey, concommand )
	self.changedBinds[ concommand ] = {
		key    = key,
		oldKey = oldKey
	}
end

function bindlistpanel:readBinds( binds )
	if ( not love.filesystem.exists( "cfg/binds.lst" ) ) then
		return
	end

	local list = {}
	for line in love.filesystem.lines( "cfg/binds.lst" ) do
		table.insert( list, line )
	end

	for i, line in ipairs( list ) do
		if ( string.len( line ) > 0 ) then
			local nextLine = list[ i + 1 ]
			if ( nextLine and string.len( nextLine ) > 0 and
			     not string.find( nextLine, "[^=]" ) ) then
				self:addHeader( line )
			elseif ( string.find( line, "[^=]" ) ) then
				local name, concommand = string.match( line, "\"(.+)\"%s(.+)" )
				concommand = string.trim( concommand )

				local key
				if ( binds ) then
					key = table.hasvalue( binds, concommand )
				else
					key = bind.getKeyForBind( concommand )
				end
				self:addBinding( name, key or '', concommand )
			end
		end
	end
end

function bindlistpanel:saveBinds()
	local i = 0
	for concommand, keys in pairs( self.changedBinds ) do
		i = i + 1
		if ( keys.oldKey ) then
			bind.setBind( keys.oldKey, nil )
		end

		if ( keys.key ) then
			bind.setBind( keys.key, concommand )
		end
	end

	-- if ( i >= 1 ) then
		bind.saveBinds()
		self.changedBinds = {}
	-- end
end

function bindlistpanel:useDefaults()
	local defaultBinds = bind.readDefaultBinds()
	for key, concommand in pairs( defaultBinds ) do
		self.changedBinds[ concommand ] = {
			key    = key,
			oldKey = bind.getKeyForBind( concommand )
		}
	end

	local innerPanel = self:getInnerPanel()
	innerPanel:removeChildren()
	self:readBinds( defaultBinds )
end
