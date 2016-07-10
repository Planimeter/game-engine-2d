--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Game Menu Stat class
--
--============================================================================--

class "hudgamemenustat" ( gui.panel )

function hudgamemenustat:hudgamemenustat( parent, name, stat )
	gui.panel.panel( self, parent, name )
	self.width        = point( 312 )
	self.height       = point( 42 )
	self.stat         = stat

	self:setScheme( "Default" )

	local progressbar = gui.progressbar( self, "Stat Progress" )
	progressbar:setY( point( 23 ) )
	self.progressbar  = progressbar

	self:addStatHook()
end

function hudgamemenustat:addStatHook()
	local function updateStat( player, stat, xp )
		if ( player ~= localplayer ) then
			return
		end

		if ( stat == self:getStat() ) then
			local xp = localplayer:getExperience( stat )
			self.progressbar:setMin( 0 )
			self.progressbar:setMax( 83 )
			self.progressbar:setValue( xp )
			self:invalidate()
		end
	end

	local stat = string.capitalize( self:getStat() )
	local name = "update" .. stat .. "Stat"
	hook.set( "shared", updateStat, "onPlayerGainedExperience", name )
end

function hudgamemenustat:draw()
	local property = "label.textColor"
	local font     = self:getScheme( "font" )
	local stat     = self:getStat()
	graphics.setColor( self:getScheme( property ) )
	graphics.setFont( font )
	graphics.print( string.capitalize( stat ), 0, 0 )

	property = "colors.gold"
	font     = self:getScheme( "fontBold" )
	local level = "Level " .. localplayer:getLevel( stat )
	local x  = self:getWidth() - font:getWidth( level )
	graphics.setColor( self:getScheme( property ) )
	graphics.setFont( font )
	graphics.print( level, x, 0 )

	property = "label.textColor"
	font     = self:getScheme( "fontSmall" )
	local xp = localplayer:getExperience( stat ) .. " / 83 XP"
	x        = self:getWidth() - font:getWidth( xp )
	graphics.setColor( self:getScheme( property ) )
	graphics.setFont( font )
	graphics.print( xp, x, point( 30 ) )

	gui.panel.draw( self )
end

function hudgamemenustat:getStat()
	return self.stat
end

function hudgamemenustat:onRemove()
	self:removeStatHook()
	gui.panel.onRemove( self )
end

function hudgamemenustat:removeStatHook()
	local stat = string.capitalize( self:getStat() )
	local name = "update" .. stat .. "Stat"
	hook.remove( "shared", "onPlayerGainedExperience", name )
end

function hudgamemenustat:setStat( stat )
	self.stat = stat
end

function hudgamemenustat:setWidth( width )
	gui.panel.setWidth( self, width )
	self.progressbar:setWidth( width )
end

gui.register( hudgamemenustat, "hudgamemenustat" )
