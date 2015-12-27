--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Sprite class
--
--============================================================================--

class( "sprite" )

function sprite:sprite( spriteSheet )
	self.data        = require( spriteSheet )
	local image      = graphics.newImage( self.data[ "image" ] )
	self.spriteSheet = image
	self.width       = self.data[ "width" ]
	self.height      = self.data[ "height" ]
	self.frametime   = self.data[ "frametime" ]
	self.animations  = self.data[ "animations" ] or {}
	self.events      = self.data[ "events" ] or {}

	self.data = nil

	-- TODO: Lazy initialize this before drawing to avoid loading the image.
	self.quad = graphics.newQuad(
		0,
		0,
		self.width,
		self.height,
		image:getWidth(),
		image:getHeight()
	)

	self.curtime = 0
	self.frame   = 0
end

function sprite:draw()
	local image = self:getSpriteSheet()
	graphics.draw( image:getDrawable(), self:getQuad() )
end

function sprite:getAnimation()
	return self.animation
end

function sprite:getAnimationName()
	return self.animationName
end

function sprite:getAnimations()
	return self.animations
end

function sprite:getEvents()
	return self.events
end

function sprite:getQuad()
	return self.quad
end

function sprite:getSpriteSheet()
	return self.spriteSheet
end

function sprite:getWidth()
	return self.width
end

function sprite:getHeight()
	return self.height
end

function sprite:onAnimationEnd( animation )
end

function sprite:onAnimationEvent( event )
end

function sprite:setAnimation( animation )
	local animations = self:getAnimations()
	local name = animation
	animation  = animations[ name ]
	if ( not animation ) then
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

function sprite:setSpriteSheet( spriteSheet )
	self.spriteSheet = spriteSheet
end

function sprite:setWidth( width )
	self.width = width
end

function sprite:setHeight( height )
	self.height = height
end

function sprite:update( dt )
	local animation = self:getAnimation()
	if ( not animation ) then
		return
	end

	self.curtime = self.curtime + dt

	if ( self.curtime >= self.frametime ) then
		self.curtime = 0
		self.frame   = self.frame + 1

		if ( self.frame > animation.to ) then
			local name = self:getAnimationName()
			self:onAnimationEnd( name )
			self.frame = animation.from
		end

		self:updateFrame()
	end
end

local floor = math.floor

function sprite:updateFrame()
	local quad         = self:getQuad()
	local frame        = self.frame == 1 and 0 or self.frame
	local spriteWidth  = self:getWidth()
	local spriteHeight = self:getHeight()
	local image        = self:getSpriteSheet()
	local imageWidth   = image:getWidth()
	local x            =        frame * spriteWidth % imageWidth
	local y            = floor( frame * spriteWidth / imageWidth ) * spriteHeight
	quad:setViewport( x, y, spriteWidth, spriteHeight )

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
