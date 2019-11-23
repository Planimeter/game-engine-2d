--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Frame HUD
--
--==========================================================================--

class "gui.hudframe" ( "gui.frame" )

local hudframe = gui.hudframe

function hudframe:hudframe( parent, name, title )
	gui.frame.frame( self, parent, name, title )

	self:setResizable( false )
	self:setMovable( false )

	if ( self.closeButton ) then
		self.closeButton:remove()
		self.closeButton = nil
	end

	self:setUseFullscreenCanvas( false )
	self:invalidateLayout()
end

local HUDFRAME_ANIM_TIME = 0.2

function hudframe:activate()
	if ( not self:isVisible() ) then
		self:setOpacity( 0 )
		self:animate( {
			opacity = 1
		}, HUDFRAME_ANIM_TIME, "easeOutQuint" )
	end

	self:moveToFront()
	self:setVisible( true )
end

function hudframe:close()
	if ( self.closing ) then
		return
	end

	self.closing = true

	self:animate( {
		opacity = 0,
	}, HUDFRAME_ANIM_TIME, "easeOutQuint", function()
		self:setVisible( false )
		self:setOpacity( 1 )

		self.closing = nil
	end )
end

function hudframe:draw()
	self:drawTranslucency()
	gui.frame.draw( self )
end

function hudframe:drawBackground()
	if ( gui._translucencyCanvas == nil ) then
		gui.panel.drawBackground( self, self:getScheme(
			"frame.backgroundColor"
		) )
		return
	end

	gui.box.drawBackground( self )
end

function hudframe:drawTitle()
	local property = "frame.titleTextColor"
	love.graphics.setColor( self:getScheme( property ) )
	local font = self:getScheme( "titleFont" )
	love.graphics.setFont( font )
	local x = math.round( 36 )
	local y = math.round( x - 4 )
	love.graphics.print( self:getTitle(), x, y )
end

function hudframe:update( dt )
	if ( gui._translucencyCanvas and self:isVisible() ) then
		self:invalidate()
	end

	gui.frame.update( self, dt )
end
