class "spriteanim"

accessor( spriteanim, "sprite" )
accessor( spriteanim, "animationName" )
accessor( spriteanim, "sequence" )

function spriteanim:spriteanim()
	self.sprIndex            = 0 -- This is the index in the owning sprite's animInstance table. (result of table.insert)
	self.curTime             = 0
	self.targetFrameTime     = 0
	self.paused              = false
	self.sequence            = {}
	self.sequenceIndex       = 1
	self.frameIndex          = 1
	self.singleFrameFinished = false
	self.loop                = true
	self.animEnded           = false
end

function spriteanim:__tostring()
	return string.format("sprite animation: %q [frame: %i]", self.animationName, self.frameIndex)
end

function spriteanim:setSequence(sequence)
	self.sequence = sequence
	self:play()
end

function spriteanim:pause()
	self.paused = true
end

function spriteanim:resume()
	self.paused = false
end

function spriteanim:loop(bShouldLoop)
	self.loop = toboolean(bShouldLoop)

	if (bShouldLoop) then
		self:play()
	end
end

function spriteanim:play()
	self.sequenceIndex = 1
	self.curTime = 0
	self:pollCommands()
end

function spriteanim:pollCommands()
	if (self.paused) then return end

	local sequence = self.sequence
	if (self.sequenceIndex > #sequence) then return end

	local command = sequence[self.sequenceIndex]
	local spr = self:getSprite()

	if (command.command == sprite._commands.setFrameTime) then
		self.targetFrameTime = command.value
		self.curTime = 0

		-- increment sequence index and repoll to prevent frameIndex flickering
		self.sequenceIndex = self.sequenceIndex + 1
		self:pollCommands()
		return
	elseif (command.command == sprite._commands.setFrameIndex) then
		self.frameIndex = command.value

		local event = spr.events[self.frameIndex]
		if (event) then
			if (type(event) ~= "table") then
				event = { event }
			end

			for i, v in ipairs(event) do
				local status, ret = pcall(spr.onAnimationEvent, spr, v)
				if (not status) then print(ret) end
			end
		end
	else
		error(string.format("Invalid sprite command %q", tostring(command.command)))
	end

	self.sequenceIndex = self.sequenceIndex + 1 -- Increment after so we dont have to bounds check it because lazy

	if ( self.sequenceIndex > #sequence ) then
		if (self.loop) then
			self.sequenceIndex = 1
		end

		local name = self:getAnimationName()
		local status, ret = pcall(spr.onAnimationEnd, spr, name )
		if (not status) then print(ret) end
	end
end

function spriteanim:update(dt)
	if (self.paused) then return end

	local spr = self:getSprite()
	if (not spr) then return end

	local sequence = self:getSequence()
	if ( #sequence == 0 or (self.singleFrameFinished and #sequence == 1) ) then return end

	self.curTime = self.curTime + dt

	if ( self.curTime >= self.targetFrameTime ) then
		self.curTime = 0

		self:pollCommands()

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
