--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Sprite class
--
--==========================================================================--

require("engine.client.spriteAnimator")

class( "sprite" )

function sprite:sprite( spriteSheet )
	if (spriteSheet) then
		self:setSpriteSheet(spriteSheet)
	else
		self.width       = 0
		self.height      = 0
		self.frametime   = 0
		self.animations  = {}
		self.events      = {}
	end

	self.curtime     = 0
	self.frame       = 1
end

function sprite:draw()
	local image = self:getSpriteSheet()
	if (not image) then return end

	love.graphics.draw( image, self:getQuad() )
end

accessor( sprite, "animator" )

function sprite:setFilter( ... )
	local image = self:getSpriteSheet()
	if (not image) then return end

	image:setFilter( ... )
end

function sprite:getQuad()
	if ( self.quad == nil and self.spriteSheet) then
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
	if (not self.animator) then return end
	self.animator:setAnimation(animation)
end

function sprite:update( dt )
	if (self.animator) then
		self.animator:update(dt)
	end
end

function sprite:updateQuad()
	if (not self.animator) then return end

	local animation = self.animator:getAnimation()
	if (#animation == 0) then return end

	local quad       = self:getQuad()
	local frame      = animation[self.animator.frameIndex] - 1
	local width      = self:getWidth()
	local height     = self:getHeight()
	local image      = self:getSpriteSheet()
	local imageWidth = image:getWidth()
	local x          =             frame * width % imageWidth
	local y          = math.floor( frame * width / imageWidth ) * height
	quad:setViewport( x, y, width, height )
end

function sprite:__tostring()
	local t = getmetatable( self )
	setmetatable( self, {} )
	local s = string.gsub( tostring( self ), "table", "sprite" )
	setmetatable( self, t )
	return s
end

function sprite:setSpriteSheet(spriteSheet)
	local data       = require( spriteSheet )
	self.spriteSheet = love.graphics.newImage( data[ "image" ] )

	self.animator = spriteAnimator(self)
	self.animator:setAnimations(data[ "animations" ] or {})
	self.animator:setEvents(data[ "events" ] or {})
	self.animator:setFrametime(data[ "frametime" ])

	self.width       = data[ "width" ]
	self.height      = data[ "height" ]
end
