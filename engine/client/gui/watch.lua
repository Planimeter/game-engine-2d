--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Watch class
--
--==========================================================================--

class "gui.watch" ( "gui.label" )

local watch = gui.watch

function watch:watch( parent, name )
	gui.label.label( self, parent, name, text )

	self:setScheme( "Console" )
	self.font    = self:getScheme( "font" )
	local margin = gui.scale( 96 )
	self.width   = love.graphics.getWidth() - 2 * margin
	self.height  = self.font:getHeight()

	self:setScheme( "Default" )
	self:invalidateLayout()
end

function watch:update( dt )
	-- HACKHACK: Fade this out for readability.
	if ( g_HudMoveIndicator and g_HudMoveIndicator._entity ) then
		self:setOpacity( 0 )
	else
		self:setOpacity( 1 )
	end

	local f, err = loadstring( "return " .. self:getExpression() )
	local ret = "?"
	if ( f ) then
		local status, err = pcall( f )
		if ( status == false ) then
			self:invalidate()
			return
		end
	else
		ret = err
	end

	self:setText( self:getExpression() .. " = " .. tostring(
		f and f() or ret
	) )
	self:invalidate()
end

gui.accessor( watch, "expression" )

function watch:invalidateLayout()
	local margin = gui.scale( 96 )
	local x      = margin
	local y      = margin + 28
	self:setPos( x, y )

	gui.panel.invalidateLayout( self )
end
