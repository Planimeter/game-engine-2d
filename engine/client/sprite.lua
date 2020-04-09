--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Sprite class
--
--==========================================================================--

class( "sprite" )

function sprite:sprite( spriteSheet )
	local data       = require( spriteSheet )
	local image      = love.graphics.newImage( data[ "image" ] )
	self.spriteSheet = image
	self.width       = data[ "width" ]
	self.height      = data[ "height" ]
	self.frametime   = data[ "frametime" ]
	self.animations  = data[ "animations" ] or {}
	self.events      = data[ "events" ]     or {}

	self.curtime     = 0
	self.frame       = 1
end

function sprite:draw()
	local image = self:getSpriteSheet()
	love.graphics.draw( image, self:getQuad() )
end

accessor( sprite, "animation" )
accessor( sprite, "animationName" )
accessor( sprite, "animations" )
accessor( sprite, "events" )
accessor( sprite, "frametime" )

function sprite:setFilter( ... )
	local image = self:getSpriteSheet()
	image:setFilter( ... )
end

function sprite:getQuad()
	if ( self.quad == nil ) then
		local image = self:getSpriteSheet()
		self.quad = love.graphics.newQuad(
			0,
			0,
			self:getWidth(),
			self:getHeight(),
			image:getWidth(),
			image:getHeight()
		)
	end

	return self.quad
end

accessor( sprite, "spriteSheet" )
accessor( sprite, "width" )
accessor( sprite, "height" )

function sprite:onAnimationEnd( animation )
end

function sprite:onAnimationEvent( event )
end

function sprite:setAnimation( animation )
	local animations = self:getAnimations()
	local name = animation
	animation  = animations[ name ]
	if ( animation == nil ) then
		return
	end

	if ( animation == self:getAnimation() ) then
		return
	end

	self.animation     = animation
	self.animationName = name
	self.frame         = animation.from

	self:updateFrame()
end

function sprite:update( dt )
	local animation = self:getAnimation()
	if ( animation == nil ) then
		return
	end

	self.curtime = self.curtime + dt

	if ( self.curtime >= self.frametime ) then
		self.curtime = 0
		self.frame   = self.frame + 1

		if ( self.frame > animation.to ) then
			local name = self:getAnimationName()
			self.frame = animation.from
			self:onAnimationEnd( name )
		end

		self:updateFrame()
	end
end

function sprite:updateFrame()
	local quad       = self:getQuad()
	local frame      = self.frame - 1
	local width      = self:getWidth()
	local height     = self:getHeight()
	local image      = self:getSpriteSheet()
	local imageWidth = image:getWidth()
	local x          =             frame * width % imageWidth
	local y          = math.floor( frame * width / imageWidth ) * height
	quad:setViewport( x, y, width, height )

	local events = self:getEvents()
	local event  = events[ frame ]
	if ( event ) then
		self:onAnimationEvent( event )
	end
end

function sprite:__tostring()
	local t = getmetatable( self )
	setmetatable( self, {} )
	local s = string.gsub( tostring( self ), "table", "sprite" )
	setmetatable( self, t )
	return s
end
