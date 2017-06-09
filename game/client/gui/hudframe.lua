--=========== Copyright © 2017, Planimeter, All rights reserved. ===========--
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

	self:setUseFullscreenFramebuffer( false )
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
	self:drawBlur()
	gui.frame.draw( self )
end

function hudframe:drawBackground()
	if ( not gui._blurFramebuffer ) then
		gui.panel.drawBackground( self, "frame.backgroundColor" )
		return
	end

	gui.panel.drawBackground( self, "hudframe.backgroundColor" )
end

function hudframe:drawBlur()
	if ( not gui._blurFramebuffer ) then
		return
	end

	gui.panel._maskedPanel = self
	love.graphics.stencil( gui.panel.drawMask )
	love.graphics.setStencilTest( "greater", 0 )
		love.graphics.push()
			local x, y = self:localToScreen()
			love.graphics.translate( -x, -y )
			gui._blurFramebuffer:draw()
		love.graphics.pop()
	love.graphics.setStencilTest()
end

function hudframe:drawTitle()
	local property = "frame.titleTextColor"
	love.graphics.setColor( self:getScheme( property ) )
	local font = self:getScheme( "titleFont" )
	love.graphics.setFont( font )
	local x = love.window.toPixels( 36 )
	local y = x - love.window.toPixels( 4 )
	love.graphics.print( string.utf8upper( self:getTitle() ), x, y )
end

function hudframe:update( dt )
	if ( gui._blurFramebuffer and self:isVisible() ) then
		self:invalidate()
	end

	gui.frame.update( self, dt )
end
