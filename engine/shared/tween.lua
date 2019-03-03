--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Inbetweening interface
--
--==========================================================================--

local math = math

class( "tween" )

local pi  = math.pi
local cos = math.cos

tween.easing = {
	linear       = function( p ) return p end,
	swing        = function( p ) return 0.5 - cos( p * pi ) / 2 end,
	easeOutQuint = function( x, t, b, c, d )
		local temp = t / d - 1
		t = t / d - 1
		return c * ( ( temp ) * t * t * t * t + 1 ) + b
	end
}

function tween:tween( target, duration, vars )
	self.target     = target
	self.startTime  = nil
	self.tweens     = {}
	self.duration   = duration or 0.4
	self.easing     = vars.easing or "swing"
	self.onUpdate   = vars.onUpdate
	self.onComplete = vars.onComplete

	vars.easing     = nil
	vars.onUpdate   = nil
	vars.onComplete = nil

	for member, value in pairs( vars ) do
		self.tweens[ member ] = {
			startValue = self.target[ member ],
			endValue   = value,
		}
	end
end

local startTime  = 0
local duration   = 0
local remaining  = 0
local max        = math.max
local percent    = 0
local startValue = 0
local endValue   = 0
local eased      = 0
local onComplete = nil

function tween:update( dt )
	if ( self.startTime == nil ) then
		self.startTime = love.timer.getTime()
	end

	startTime = self.startTime
	duration  = self.duration
	remaining = max( 0, startTime + duration - love.timer.getTime() )
	percent   = 1 - ( remaining / duration or 0 )
	self.pos  = percent

	for member, t in pairs( self.tweens ) do
		startValue = t.startValue
		endValue   = t.endValue
		eased      = tween.easing[ self.easing ](
			percent, duration * percent, 0, 1, duration
		)
		self.target[ member ] = ( endValue - startValue ) * eased + startValue

		if ( self.onUpdate ) then
			self.onUpdate()
		end
	end

	if ( percent == 1 ) then
		onComplete = self.onComplete
		if ( onComplete ) then
			onComplete()
		end
	end
end
