class ("spriteAnimator")

accessor(spriteAnimator, "frametime")
accessor(spriteAnimator, "animation")
accessor(spriteAnimator, "animationName")
accessor(spriteAnimator, "animations")
accessor(spriteAnimator, "events")

function spriteAnimator:spriteAnimator(sprite)
	self.sprite        = sprite
	self.animations    = {}
	self.events        = {}

	self.curtime       = 0
	self.frametime     = 0
	self.frameIndex    = 1
	self.animation     = nil
	self.animationName = ""
end

--[[
	animTbl = {
		animName = {
			frame1, frame2, { from = frame3, to = frame7 }, ...
		}
	}
]]
function spriteAnimator:setAnimations(animTbl)
	assert(type(animTbl) == "table", "animTbl must be a table")

	for animName, frameTbl in pairs(animTbl) do
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

function spriteAnimator:setAnimation( name )
	local animations = self:getAnimations()
	local animation  = animations[ name ]

	if ( animation == nil ) then return end
	if ( animation == self:getAnimation() ) then return end

	self.animation     = animation
	self.animationName = name
	self.frameIndex    = 1

	self.sprite:updateQuad()
end

function spriteAnimator:update( dt )
	local animation = self:getAnimation()

	if ( animation == nil ) then return end

	self.curtime = self.curtime + dt

	if ( self.curtime >= self.frametime ) then
		self.curtime = 0
		self.frameIndex = self.frameIndex + 1

		if ( self.frameIndex > #self.animation ) then
			self.frameIndex = 1
			local name = self:getAnimationName()
			self.sprite:onAnimationEnd( name )
		end

		self.sprite:updateQuad()
	end
end

function spriteAnimator:checkEvents()
	local event = self.events[self.animation[self.frameIndex]]
	if (not event) then return end

	self.sprite:onAnimationEvent( event )
end
