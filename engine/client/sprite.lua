--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Sprite class
--
--==========================================================================--

require( "engine.client.spriteanim" )

class( "sprite" )

accessor( sprite, "spriteSheet" )
accessor( sprite, "spriteSheetName" )
accessor( sprite, "width" )
accessor( sprite, "height" )
accessor( sprite, "frameTime" )
accessor( sprite, "animations" )
accessor( sprite, "events" )

function sprite:sprite( spriteSheet )
	-- Make sure this exists before loading a sprite sheet
	self.animations      = {}

	if (spriteSheet) then
		self:setSpriteSheet(spriteSheet)
	else
		self.spriteSheetName = ""
		self.width           = 0
		self.height          = 0
		self.frameTime       = 0
		self.events          = {}
	end

	self.animInstances = {}
	self.curAnim       = nil
end

function sprite:draw()
	local image = self:getSpriteSheet()
	if (not image) then return end

	love.graphics.draw( image, self:getQuad() )
end

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

function sprite:onAnimationEnd( animation )
end

function sprite:onAnimationEvent( event )
end

function sprite:setAnimation( animation )
	if (typeof(animation, "spriteanim")) then
		self.curAnim = animation
	elseif (type(animation) == "string") then
		if (not self.curAnim or (self.curAnim and self.curAnim:getAnimationName() ~= animation)) then
			local instance = self:createAnimInstance(animation);
			instance:remove()
			instance:setSprite(self)
			instance.sprIndex = 0
			self.animInstances[0] = instance
			self.curAnim = instance
		end
	elseif (not animation) then
		self.curAnim = nil
	else
		error(string.format("Invalid animation type %q", type(animation)))
	end

	self:updateQuad()
end

function sprite:getAnimation()
	return self.curAnim
end

function sprite:update( dt )
	for index = 0, table.getn(self.animInstances) do
		local instance = self.animInstances[index]
		if (instance and not instance.paused) then
			instance:update(dt)

			local event = self.events[instance.frameIndex]
			if (event) then
				local status, ret = pcall(self.onAnimationEnd, self, event)
				if (not status) then print(ret) end
			end
		end
	end
end

function sprite:updateQuad()
	if (not self.curAnim) then return end

	local quad       = self:getQuad()
	local frame      = self.animations[self.curAnim:getAnimationName()][self.curAnim.frameIndex] - 1
	local width      = self:getWidth()
	local height     = self:getHeight()
	local image      = self:getSpriteSheet()
	local imageWidth = image:getWidth()
	local x          =             frame * width % imageWidth
	local y          = math.floor( frame * width / imageWidth ) * height
	quad:setViewport( x, y, width, height )
end

function sprite:loadAnimations(animations)
	assert(type(animations) == "table", "animTbl must be a table")

	for animName, frameTbl in pairs(animations) do
		local expanded = {}

		for index, frame in ipairs(frameTbl) do
			if (type(frame) == "number") then
				table.insert(expanded, frame)
			elseif (type(frame) == "table") then
				assert(type(frame["from"]) == "number", "frameTbl range table \"from\" must be a frame index")
				assert(type(frame["to"]) == "number", "frameTbl range table \"to\" must be a frame index")
				for frameIndex = frame.from, frame.to, (frame.to < frame.from and -1 or 1) do
					table.insert(expanded, frameIndex)
				end
			else
				assert(false, "frameTbl must contain frame indices, or a range table")
			end
		end

		self.animations[animName] = expanded
	end
end

function sprite:createAnimInstance(animName)
	local animations = self:getAnimations()
	local frames  = animations[ animName ]

	assert(frames, string.format("Sprite Sheet %q does not contain animation %q", self:getSpriteSheetName(), animName))

	local instance = spriteanim()
	instance:setSprite(self)
	instance:setFrameTime(self:getFrameTime())
	instance:setAnimationName(animName)
	instance:setFrames(frames)

	table.insert(self.animInstances, instance)
	instance.sprIndex = table.getn(self.animInstances)

	return instance
end

function sprite:__tostring()
	local t = getmetatable( self )
	setmetatable( self, {} )
	local s = string.gsub( tostring( self ), "table", "sprite" )
	setmetatable( self, t )
	return s
end

function sprite:setSpriteSheet(spriteSheet)
	local data           = require( spriteSheet )
	self.spriteSheet     = love.graphics.newImage( data[ "image" ] )
	self.spriteSheetName = spriteSheet

	self:loadAnimations(data[ "animations" ] or {})
	self:setEvents(data[ "events" ] or {})
	self:setFrameTime(data[ "frametime" ])

	self.width       = data[ "width" ]
	self.height      = data[ "height" ]
end
