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
			local level = localplayer:getLevel( stat )
			local xp    = localplayer:getExperience( stat )
			self.progressbar:setMin( vaplayer.levelToExperience( level ) )
			self.progressbar:setMax( vaplayer.levelToExperience( level + 1 ) )
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

	property    = "colors.gold"
	font        = self:getScheme( "fontBold" )
	local level = localplayer:getLevel( stat )
	local label = "Level " .. level
	local x     = self:getWidth() - font:getWidth( label )
	graphics.setColor( self:getScheme( property ) )
	graphics.setFont( font )
	graphics.print( label, x, 0 )

	property        = "label.textColor"
	font            = self:getScheme( "fontSmall" )
	local nextLvlXp = vaplayer.levelToExperience( level + 1 )
	local xp        = localplayer:getExperience( stat )
	label           = xp  .. " / " .. nextLvlXp .. " XP"
	x               = self:getWidth() - font:getWidth( label )
	graphics.setColor( self:getScheme( property ) )
	graphics.setFont( font )
	graphics.print( label, x, point( 30 ) )

	gui.panel.draw( self )
end

mutator( hudgamemenustat, "stat" )

function hudgamemenustat:onRemove()
	self:removeStatHook()
	gui.panel.onRemove( self )
end

function hudgamemenustat:removeStatHook()
	local stat = string.capitalize( self:getStat() )
	local name = "update" .. stat .. "Stat"
	hook.remove( "shared", "onPlayerGainedExperience", name )
end

function hudgamemenustat:setWidth( width )
	gui.panel.setWidth( self, width )
	self.progressbar:setWidth( width )
end

gui.register( hudgamemenustat, "hudgamemenustat" )
