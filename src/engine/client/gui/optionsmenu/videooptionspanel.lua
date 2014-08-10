--========= Copyright © 2013-2014, Planimeter, All rights reserved. ==========--
--
-- Purpose: Video Options Panel class
--
--============================================================================--

class "videooptionspanel" ( gui.frametabpanel )

function videooptionspanel:videooptionspanel()
	gui.frametabpanel.frametabpanel( self, nil, "Video Options Panel" )
	self.options = {}
	local c		 = engine.getConfig()

	local name = "Aspect Ratio"
	local label = gui.label( self, name, name )
	local x = 36
	local y = 36
	label:setPos( x, y )

	name = "Aspect Ratio Drop-Down List"
	self.aspectRatios = gui.dropdownlist( self, name )
	self.aspectRatios.onValueChanged = function( dropdownlist, oldValue, newValue )
		self.options.aspectRatio = newValue
		self:updateResolutions()
	end
	y = y + label:getHeight() + 9
	self.aspectRatios:setPos( x, y )

	name = "Resolution"
	label = gui.label( self, name, name )
	y = y + self.aspectRatios:getHeight() + 9
	label:setPos( x, y )

	name = "Resolution Drop-Down List"
	self.resolutions = gui.dropdownlist( self, name )
	self.resolutions.onValueChanged = function( dropdownlist, oldValue, newValue )
		self.options.resolution = newValue
	end
	y = y + label:getHeight() + 9
	self.resolutions:setPos( x, y )

	name = "Custom Resolution"
	self.customResolution = gui.checkbox( self, name, name )
	self.customResolution.onCheckedChanged = function( checkbox, checked )
		self.aspectRatios:setDisabled( checked )
		self.resolutions:setDisabled( checked )
		self.customWidth:setDisabled( not checked )
		self.customHeight:setDisabled( not checked )
		if ( not checked ) then
			self:updateResolutions()
		else
			if ( self.options.resolution ) then
				local width	 = tonumber( self.customWidth:getText() )
				self.options.resolution.width  = width or
				self.options.resolution.width
				local height = tonumber( self.customHeight:getText() )
				self.options.resolution.height = height or
				self.options.resolution.height
			end
		end
	end
	y = y + self.aspectRatios:getHeight() + 36
	self.customResolution:setPos( x, y )

	name = "Width"
	self.customWidth = gui.textbox( self, name, name )
	y = y + self.customResolution:getHeight() + 9
	self.customWidth:setPos( x, y )
	self.customWidth:setDisabled( true )
	self.customWidth:setDefocusOnEnter( true )
	self.customWidth.onLostFocus = function( textbox )
		local width = tonumber( textbox:getText() )
		if ( not width ) then
			return
		elseif ( width < 640 ) then
			width = 640
			textbox:setText( "640" )
		end
		self.options.resolution.width = width
	end

	name = "Height"
	self.customHeight = gui.textbox( self, name, name )
	y = y + self.customWidth:getHeight() + 9
	self.customHeight:setPos( x, y )
	self.customHeight:setDisabled( true )
	self.customHeight:setDefocusOnEnter( true )
	self.customHeight.onLostFocus = function( textbox )
		local height = tonumber( textbox:getText() )
		if ( not height ) then
			return
		elseif ( height < 480 ) then
			height = 480
			textbox:setText( "480" )
		end
		self.options.resolution.height = height
	end

	self:updateAspectRatios()
	self:updateResolutions()

	name = "Fullscreen"
	self.fullscreen = gui.checkbox( self, name, name )
	self.options.fullscreen = c.window.fullscreen
	self.fullscreen:setChecked( c.window.fullscreen )
	self.fullscreen.onCheckedChanged = function( checkbox, checked )
		self.options.fullscreen = checked
		c.window.fullscreen		= checked
	end
	x = 2 * x + self.resolutions:getWidth()
	y = 36 + label:getHeight() + 9
	self.fullscreen:setPos( x, y )

	name = "Borderless Window"
	self.borderless = gui.checkbox( self, name, name )
	self.options.borderless = c.window.borderless
	self.borderless:setChecked( c.window.borderless )
	self.borderless.onCheckedChanged = function( checkbox, checked )
		self.options.borderless = checked
		c.window.borderless		= checked
	end
	y = y + 2 * self.fullscreen:getHeight() + 4
	self.borderless:setPos( x, y )

	name = "Vertical Synchronization"
	self.vsync = gui.checkbox( self, name, name )
	self.options.vsync = c.window.vsync
	self.vsync:setChecked( c.window.vsync )
	self.vsync.onCheckedChanged = function( checkbox, checked )
		self.options.vsync = checked
		c.window.vsync	   = checked
	end
	y = y + 2 * self.borderless:getHeight() + 3
	self.vsync:setPos( x, y )
end

function videooptionspanel:activate()
	self:saveControlStates()
end

function videooptionspanel:clearCustomResolution()
	if ( not self.customResolution ) then
		return
	end

	if ( not self.customResolution:isChecked() ) then
		self.customWidth:setText( "" )
		self.customHeight:setText( "" )
	else
		local isCustomResolution = false

		local customWidth = self.customWidth:getText()
		if ( customWidth == "" or tonumber( customWidth ) == nil ) then
			self.customWidth:setText( "" )
		else
			isCustomResolution = true
		end

		local customHeight = self.customHeight:getText()
		if ( customHeight == "" or tonumber( customHeight ) == nil ) then
			self.customHeight:setText( "" )
		else
			isCustomResolution = true
		end

		if ( not isCustomResolution ) then
			self.customResolution:setChecked( false )
		end
	end
end

function videooptionspanel:onOK()
	self:updateMode()

	self:clearCustomResolution()
end

function videooptionspanel:onCancel()
	self.options.resolution = nil

	self:resetControlStates()
end

videooptionspanel.onApply = videooptionspanel.onOK

function videooptionspanel:saveControlStates()
	self.controls				   = {}
	self.controls.aspectRatios	   = self.aspectRatios:getListItemGroup():getSelectedId()
	self.controls.customResolution = self.customResolution:isChecked()
	self.controls.fullscreen	   = self.fullscreen:isChecked()
	self.controls.borderless	   = self.borderless:isChecked()
	self.controls.vsync			   = self.vsync:isChecked()
end

function videooptionspanel:resetControlStates()
	self.aspectRatios:getListItemGroup():setSelectedId( self.controls.aspectRatios )
	self.customResolution:setChecked( self.controls.customResolution )
	self.fullscreen:setChecked( self.controls.fullscreen )
	self.borderless:setChecked( self.controls.borderless )
	self.vsync:setChecked( self.controls.vsync )
	table.clear( self.controls )

	self:clearCustomResolution()
end

function videooptionspanel:updateMode()
	if ( self.options.resolution ) then
		convar.setConvar( "r_window_width",		 self.options.resolution.width )
		convar.setConvar( "r_window_height",	 self.options.resolution.height )
		convar.setConvar( "r_window_fullscreen", self.options.fullscreen and 1 or 0 )
		convar.setConvar( "r_window_borderless", self.options.borderless and 1 or 0 )
		convar.setConvar( "r_window_vsync",		 self.options.vsync		 and 1 or 0 )

		local flags	 = table.copy( engine.getConfig().window )
		flags.width	 = nil
		flags.height = nil
		flags.icon	 = nil
		graphics.setMode( self.options.resolution.width,
						  self.options.resolution.height,
						  flags )
	end
end

function videooptionspanel:updateAspectRatios()
	local supportedAspectRatios = {
		{ x = 4,   y = 3 },
		{ x = 16,  y = 9 },
	 -- { x = 683, y = 384 },
		{ x = 16,  y = 10 },
	}
	local dropdownlistitem = nil
	local name			   = "Aspect Ratio Drop-Down List Item"
	local text			   = ""
	local arx, ary		   = graphics.getViewportAspectRatio()
	for i, mode in ipairs( supportedAspectRatios ) do
		local hasModes = #graphics.getFullscreenModes( mode.x, mode.y ) ~= 0
		-- HACKHACK: Include 683:384 when performing 16:9 lookups
		if ( mode.x == 16 and mode.y == 9 and not hasModes ) then
			hasModes = #graphics.getFullscreenModes( 683, 384 ) ~= 0
		end

		if ( hasModes ) then
			text = mode.x .. ":" .. mode.y
			dropdownlistitem = gui.dropdownlistitem( name .. " " .. i, text )
			dropdownlistitem:setValue( mode )
			self.aspectRatios:addItem( dropdownlistitem )
			if ( mode.x == arx and mode.y == ary ) then
				dropdownlistitem:setDefault( true )
				self.options.aspectRatio = mode
			elseif ( not self.options.aspectRatio ) then
				self.options.aspectRatio = mode
			end
		end
	end

end

function videooptionspanel:updateResolutions()
	local listItemGroup = self.resolutions:getListItemGroup()
	local items			= listItemGroup:getItems()
	if ( items ) then
		for i = #items, 1, -1 do
			items[ i ]:remove()
			items[ i ] = nil
		end
		self.resolutions:invalidate()
	end
	self.options.resolution = nil

	local r		= self.options.aspectRatio
	local modes = graphics.getFullscreenModes( r.x, r.y )
	-- HACKHACK: Include 683:384 when performing 16:9 lookups
	if ( r.x == 16 and r.y == 9 ) then
		table.append( modes, graphics.getFullscreenModes( 683, 384 ) )
		table.sort( modes, function( a, b )
			return a.width * a.height < b.width * b.height
		end )
	end
	local dropdownlistitem = nil
	local name			   = "Resolution Drop-Down List Item"
	local text			   = ""
	local foundMode		   = false
	for i, mode in ipairs( modes ) do
		text			 = mode.width .. " × " .. mode.height
		dropdownlistitem = gui.dropdownlistitem( name .. " " .. i, text )
		dropdownlistitem:setValue( mode )
		self.resolutions:addItem( dropdownlistitem )
		if ( mode.width	 == graphics.getViewportWidth() and
			 mode.height == graphics.getViewportHeight() ) then
			dropdownlistitem:setDefault( true )
			foundMode = true
		end
		if ( not self.options.resolution ) then
			self.options.resolution = mode
		end
	end

	if ( not foundMode ) then
		self.customWidth:setText( tostring( graphics.getViewportWidth() ) )
		self.customHeight:setText( tostring( graphics.getViewportHeight() ) )
	else
		self:clearCustomResolution()
	end
end

gui.register( videooptionspanel, "videooptionspanel" )
