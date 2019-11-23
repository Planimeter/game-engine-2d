--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Frame Tab class
--
--==========================================================================--

class "gui.frametab" ( "gui.radiobutton" )

local frametab = gui.frametab

function frametab:frametab( parent, name, text )
	gui.radiobutton.radiobutton( self, parent, name, text )
	self:setDisplay( "inline-block" )
	self:setPadding( 22 )
	self.text:set( text )
	self.width  = nil
	self.height = nil
end

function frametab:draw()
	self:drawBackground()
	self:drawText()
	gui.box.draw( self )
end

function frametab:drawBackground()
	local color     = self:getScheme( "frametab.backgroundColor" )
	local mouseover = self.mouseover or self:isChildMousedOver()
	local width     = self:getWidth()
	local height    = self:getHeight()


	if ( self:isSelected() ) then
		color = self:getScheme( "frametab.selected.backgroundColor" )
	elseif ( mouseover ) then
		gui.panel.drawBackground( self, color )
		color = self:getScheme( "frametab.mouseover.backgroundColor" )
	end

	love.graphics.setColor( color )

	local selected  = mouseover or      self:isSelected()
	mouseover       = mouseover and not self:isSelected()
	love.graphics.rectangle(
		"fill",
		0,
		0,
		width  - ( selected  and 1 or 0 ),
		height - ( mouseover and 1 or 0 )
	)

	local lineWidth = 1
	if ( selected ) then
		love.graphics.setColor( self:getScheme( "frametab.backgroundColor" ) )
		love.graphics.setLineStyle( "rough" )
		love.graphics.setLineWidth( lineWidth )
		love.graphics.line(
			width - lineWidth / 2, 0,     -- Top-left
			width - lineWidth / 2, height -- Bottom-left
		)
	end

	selected = self:isSelected()
	love.graphics.setColor( self:getScheme( "frametab.borderColor" ) )
	love.graphics.setLineStyle( "rough" )
	love.graphics.setLineWidth( lineWidth )
	love.graphics.line(
		width - lineWidth / 2, 0,
		width - lineWidth / 2, height - ( selected and 0 or 1 )
	)

	if ( not selected ) then
		love.graphics.line(
			0,     height - lineWidth / 2, -- Top-right
			width, height - lineWidth / 2  -- Bottom-right
		)
	end
end

function frametab:mousepressed( x, y, button, istouch )
	if ( ( self.mouseover or self:isChildMousedOver() ) and button == 1 ) then
		self.mousedown = true

		if ( not self:isDisabled() ) then
			local frametabgroup = self:getGroup()
			if ( frametabgroup ) then
				frametabgroup:setSelectedId( self.id )
				self:onClick()
			end
		end
	end

	self:invalidate()
end

function frametab:mousereleased( x, y, button, istouch )
	self.mousedown = false
	self:invalidate()
end
