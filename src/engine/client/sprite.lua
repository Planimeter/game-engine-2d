--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Sprite class
--
--============================================================================--

class( "sprite" )

function sprite:sprite( spriteSheet )
	self.spriteSheet = graphics.newSpriteBatch( spriteSheet )
	self.width		 = 0
	self.height		 = 0
end

function sprite:draw()
	graphics.draw( self:getSpriteSheet() )
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

function sprite:setSpriteSheet( spriteSheet )
	self.spriteSheet = spriteSheet
end

function sprite:setWidth( width )
	self.width = width
end

function sprite:setHeight( height )
	self.height = height
end

function sprite:__tostring()
	local t = getmetatable( self )
	setmetatable( self, {} )
	local s = string.gsub( tostring( self ), "table", "sprite" )
	setmetatable( self, t )
	return s
end
