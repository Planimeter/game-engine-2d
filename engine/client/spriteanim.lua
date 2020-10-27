class "spriteanim"

accessor( spriteanim, "sprite" )
accessor( spriteanim, "frameTime" )
accessor( spriteanim, "animationName" )
accessor( spriteanim, "frames" )

function spriteanim:spriteanim()
	self.sprIndex            = 0 -- This is the index in the owning sprite's animInstance table. (result of table.insert)
	self.curTime             = 0
	self.paused              = false
	self.frames              = {}
	self.frameIndex          = 1
	self.singleFrameFinished = false
	self.loop                = true
	self.animEnded           = false
end

function spriteanim:pause()
	self.paused = true
end

function spriteanim:resume()
	self.paused = false
end

function spriteanim:loop(bShouldLoop)
	self.loop = toboolean(bShouldLoop)
	self:play()
end

function spriteanim:play()
	self.frameIndex = 1
	self.curTime = 0
end

function spriteanim:update(dt)
	local spr = self:getSprite()
	local frames = self:getFrames()

	if ( not spr or #frames == 0 or (self.singleFrameFinished and #frames == 1)  or self.paused ) then return end

	self.curTime = self.curTime + dt

	if ( self.curTime >= spr:getFrameTime() ) then
		self.curTime = 0
		self.frameIndex = self.frameIndex + 1

		-- This should always pass when the animation is a single frame
		if ( self.frameIndex > #frames ) then
			if (self.loop) then
				self.frameIndex = 1
			else
				self.frameIndex = #frames
			end

			local name = self:getAnimationName()
			local status, ret = pcall(spr.onAnimationEnd, spr, name )
			if (not status) then print(ret) end
		end

		spr:updateQuad()
		self.singleFrameFinished = true
	end
end

function spriteanim:remove()
	local spr = self:getSprite()
	if (not spr) then return end

	local instances = spr.animInstances
	if (instances[self.sprIndex] == self) then -- prevent accidentally removing another anim at the same index.. just in case
		table.remove(instances, self.sprIndex)
	end

	self:setSprite(nil)
end
