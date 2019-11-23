--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Profiler HUD
--
--==========================================================================--

class "gui.hudprofiler" ( "gui.hudframe" )

local hudprofiler = gui.hudprofiler

function hudprofiler:hudprofiler( parent )
	local name = "HUD Profiler"
	gui.hudframe.hudframe( self, parent, name, name )
	self.width  = 320 -- - 31
	self.height = 432
	self:setBorderColor( self:getScheme( "borderColor" ) )

	local budgets = profile._stack
	for i, budget in ipairs( budgets ) do
		local box = gui.box( self, budget.name .. " Budget Info" )
		box:setDisplay( "block" )
		box:setMargin( 16, 0 )
		local text = gui.text( box, budget.name )
		text:setColor( self:getScheme( "textColor" ) )
		gui.progressbar( box )
	end

	self:invalidateLayout()
end

function hudprofiler:draw()
	self:drawTranslucency()
	self:drawBackground()

	gui.box.draw( self )

	self:drawTitle()
	-- self:drawBorder( self:getScheme( "borderColor" ) )

	if ( convar.getConvar( "gui_draw_frame_focus" ):getBoolean() and
	     self.focus ) then
		self:drawSelection()
	end
end

function hudprofiler:getTitle()
	return "Profiler"
end

function hudprofiler:invalidateLayout()
	local x = love.graphics.getWidth()  - self:getWidth()  - 18
	local y = love.graphics.getHeight() - self:getHeight() - 18
	self:setPos( x, y )
	gui.frame.invalidateLayout( self )
end

concommand( "+profiler", "Opens the profiler", function()
	local visible = _G.g_Profiler:isVisible()
	if ( not visible ) then
		_G.g_Profiler:activate()
	end
end, { "game" } )

concommand( "-profiler", "Closes the profiler", function()
	local visible = _G.g_Profiler:isVisible()
	if ( visible ) then
		_G.g_Profiler:close()
	end
end, { "game" } )

local function onReloadScript()
	local profiler = g_Profiler
	if ( profiler == nil ) then
		return
	end

	local visible = profiler:isVisible()
	profiler:remove()
	profiler = gui.hudprofiler( g_Viewport )
	g_Profiler = profiler
	if ( visible ) then
		profiler:activate()
	end
end

onReloadScript()
