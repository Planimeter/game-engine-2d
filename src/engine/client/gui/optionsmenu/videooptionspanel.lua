--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Video Options Panel class
--
--============================================================================--

class "videooptionspanel" ( gui.frametabpanel )

function videooptionspanel:videooptionspanel()
	gui.frametabpanel.frametabpanel( self, nil, "Video Options Panel" )
	local options = {}
	self.options = options
	local c = engine.getConfig()

	local name = "Aspect Ratio"
	local label = gui.label( self, name, name )
	local x = 36
	local y = 36
	label:setPos( x, y )
	label:setFont( self:getScheme( "fontBold" ) )

	name = "Aspect Ratio Drop-Down List"
	local aspectRatios = gui.dropdownlist( self, name )
	self.aspectRatios = aspectRatios
	aspectRatios.onValueChanged = function( dropdownlist, oldValue, newValue )
		options.aspectRatio = newValue
		self:updateResolutions()
	end
	y = y + label:getHeight() + 9
	aspectRatios:setPos( x, y )

	name = "Resolution"
	label = gui.label( self, name, name )
	y = y + aspectRatios:getHeight() + 9
	label:setPos( x, y )
	label:setFont( self:getScheme( "fontBold" ) )

	name = "Resolution Drop-Down List"
	local resolutions = gui.dropdownlist( self, name )
	self.resolutions = resolutions
	resolutions.onValueChanged = function( dropdownlist, oldValue, newValue )
		options.resolution = newValue
	end
	y = y + label:getHeight() + 9
	resolutions:setPos( x, y )

	name = "Custom Resolution"
	local customResolution = gui.checkbox( self, name, name )
	self.customResolution = customResolution
	customResolution.onCheckedChanged = function( checkbox, checked )
		aspectRatios:setDisabled( checked )
		resolutions:setDisabled( checked )

		local customWidth = self.customWidth
		customWidth:setDisabled( not checked )

		local customHeight = self.customHeight
		customHeight:setDisabled( not checked )

		if ( not checked ) then
			self:updateResolutions()
		else
			local resolution = options.resolution
			if ( resolution ) then
				local width = tonumber( customWidth:getText() )
				resolution.width = width or resolution.width

				local height = tonumber( customHeight:getText() )
				resolution.height = height or resolution.height
			end
		end
	end
	y = y + aspectRatios:getHeight() + 36
	customResolution:setPos( x, y )

	name = "Width"
	local customWidth = gui.textbox( self, name, name )
	self.customWidth = customWidth
	y = y + customResolution:getHeight() + 9
	customWidth:setPos( x, y )
	customWidth:setDisabled( true )
	customWidth:setDefocusOnEnter( true )
	customWidth.onLostFocus = function( textbox )
		local width = tonumber( textbox:getText() )
		if ( not width ) then
			return
		elseif ( width < 640 ) then
			width = 640
			textbox:setText( "640" )
		end
		options.resolution.width = width
	end

	name = "Height"
	local customHeight = gui.textbox( self, name, name )
	self.customHeight = customHeight
	y = y + customWidth:getHeight() + 9
	customHeight:setPos( x, y )
	customHeight:setDisabled( true )
	customHeight:setDefocusOnEnter( true )
	customHeight.onLostFocus = function( textbox )
		local height = tonumber( textbox:getText() )
		if ( not height ) then
			return
		elseif ( height < 480 ) then
			height = 480
			textbox:setText( "480" )
		end
		options.resolution.height = height
	end

	self:updateAspectRatios()
	self:updateResolutions()

	name = "Fullscreen"
	local fullscreen = gui.checkbox( self, name, name )
	self.fullscreen = fullscreen
	local window = c.window
	options.fullscreen = window.fullscreen
	fullscreen:setChecked( window.fullscreen )
	fullscreen.onCheckedChanged = function( checkbox, checked )
		options.fullscreen = checked
		window.fullscreen = checked
	end
	x = 2 * x + resolutions:getWidth()
	y = 36 + label:getHeight() + 9
	fullscreen:setPos( x, y )

	name = "Borderless Window"
	local borderless = gui.checkbox( self, name, name )
	self.borderless = borderless
	options.borderless = window.borderless
	borderless:setChecked( window.borderless )
	borderless.onCheckedChanged = function( checkbox, checked )
		options.borderless = checked
		window.borderless = checked
	end
	y = y + 2 * fullscreen:getHeight() + 4
	borderless:setPos( x, y )

	name = "Vertical Synchronization"
	local vsync = gui.checkbox( self, name, name )
	self.vsync = vsync
	options.vsync = window.vsync
	vsync:setChecked( window.vsync )
	vsync.onCheckedChanged = function( checkbox, checked )
		options.vsync = checked
		window.vsync = checked
	end
	y = y + 2 * borderless:getHeight() + 3
	vsync:setPos( x, y )
end

function videooptionspanel:activate()
	self:saveControlStates()
end

function videooptionspanel:clearCustomResolution()
	local customResolution = self.customResolution
	if ( not customResolution ) then
		return
	end

	if ( not customResolution:isChecked() ) then
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
			customResolution:setChecked( false )
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
	local controls            = {}
	self.controls             = controls
	controls.aspectRatios     = self.aspectRatios:getListItemGroup():getSelectedId()
	controls.customResolution = self.customResolution:isChecked()
	controls.fullscreen       = self.fullscreen:isChecked()
	controls.borderless       = self.borderless:isChecked()
	controls.vsync            = self.vsync:isChecked()
end

function videooptionspanel:resetControlStates()
	local controls = self.controls
	self.aspectRatios:getListItemGroup():setSelectedId( controls.aspectRatios )
	self.customResolution:setChecked( controls.customResolution )
	self.fullscreen:setChecked( controls.fullscreen )
	self.borderless:setChecked( controls.borderless )
	self.vsync:setChecked( controls.vsync )
	table.clear( controls )

	self:clearCustomResolution()
end

function videooptionspanel:updateMode()
	local options    = self.options
	local resolution = options.resolution
	if ( resolution ) then
		convar.setConvar( "r_window_width",      resolution.width )
		convar.setConvar( "r_window_height",     resolution.height )
		convar.setConvar( "r_window_fullscreen", options.fullscreen and 1 or 0 )
		convar.setConvar( "r_window_borderless", options.borderless and 1 or 0 )
		convar.setConvar( "r_window_vsync",      options.vsync      and 1 or 0 )

		local flags  = table.copy( engine.getConfig().window )
		flags.width  = nil
		flags.height = nil
		flags.icon   = nil
		graphics.setMode( resolution.width, resolution.height, flags )
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
	local name = "Aspect Ratio Drop-Down List Item"
	local text = ""
	local arx, ary = graphics.getViewportAspectRatio()
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
			local options = self.options
			if ( mode.x == arx and mode.y == ary ) then
				dropdownlistitem:setDefault( true )
				options.aspectRatio = mode
			elseif ( not options.aspectRatio ) then
				options.aspectRatio = mode
			end
		end
	end

end

function videooptionspanel:updateResolutions()
	local resolutions = self.resolutions
	local listItemGroup = resolutions:getListItemGroup()
	local items = listItemGroup:getItems()
	if ( items ) then
		for i = #items, 1, -1 do
			items[ i ]:remove()
			items[ i ] = nil
		end
		resolutions:invalidate()
	end
	local options = self.options
	options.resolution = nil

	local r = options.aspectRatio
	local modes = graphics.getFullscreenModes( r.x, r.y )
	-- HACKHACK: Include 683:384 when performing 16:9 lookups
	if ( r.x == 16 and r.y == 9 ) then
		table.append( modes, graphics.getFullscreenModes( 683, 384 ) )
		table.sort( modes, function( a, b )
			return a.width * a.height < b.width * b.height
		end )
	end
	local dropdownlistitem = nil
	local name = "Resolution Drop-Down List Item"
	local text = ""
	local foundMode = false
	local width = graphics.getViewportWidth()
	local height = graphics.getViewportHeight()
	for i, mode in ipairs( modes ) do
		text = mode.width .. " × " .. mode.height
		dropdownlistitem = gui.dropdownlistitem( name .. " " .. i, text )
		dropdownlistitem:setValue( mode )
		resolutions:addItem( dropdownlistitem )
		if ( mode.width == width and mode.height == height ) then
			dropdownlistitem:setDefault( true )
			foundMode = true
		end
		if ( not options.resolution ) then
			options.resolution = mode
		end
	end

	if ( not foundMode ) then
		self.customWidth:setText( tostring( width ) )
		self.customHeight:setText( tostring( height ) )
	else
		self:clearCustomResolution()
	end
end

gui.register( videooptionspanel, "videooptionspanel" )
