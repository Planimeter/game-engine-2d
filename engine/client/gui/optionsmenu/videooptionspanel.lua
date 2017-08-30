--=========== Copyright © 2017, Planimeter, All rights reserved. ===========--
--
-- Purpose: Video Options Panel class
--
--==========================================================================--

class "gui.videooptionspanel" ( "gui.frametabpanel" )

local videooptionspanel = gui.videooptionspanel

function videooptionspanel.getAspectRatio()
	local w = love.graphics.getWidth()
	local h = love.graphics.getHeight()
	local r = math.gcd( w, h )
	return w / r, h / r
end

function videooptionspanel.getAspectRatios()
	local modes = videooptionspanel.getFullscreenModes()
	local r     = 1
	for i, mode in ipairs( modes ) do
		r = math.gcd( mode.width, mode.height )
		mode.x = mode.width  / r
		mode.y = mode.height / r
		mode.width  = nil
		mode.height = nil
	end
	table.sort( modes, function( a, b )
		return a.x * a.y < b.x * b.y
	end )
	modes = table.unique( modes )
	return modes
end

function videooptionspanel.getFullscreenModes( x, y )
	local modes = love.window.getFullscreenModes()
	for i = #modes, 1, -1 do
		local mode = modes[ i ]
		local w, h = mode.width, mode.height
		if ( w >= 800 and h >= 600 ) then
			local r  = math.gcd( w, h )
			local mx = w / r
			local my = h / r
			if ( not ( mx == x and my == y ) ) then
				table.remove( modes, i )
			end
		else
			table.remove( modes, i )
		end
	end
	table.sort( modes, function( a, b )
		return a.width * a.height < b.width * b.height
	end )
	return modes
end

function videooptionspanel:videooptionspanel( parent, name )
	parent = parent or nil
	name = name or "Video Options Panel"
	gui.frametabpanel.frametabpanel( self, parent, name )
	local options = {}
	self.options = options
	local c = config.getConfig()

	local name = "Aspect Ratio"
	local label = gui.label( self, name, name )
	local margin = love.window.toPixels( 36 )
	local x = margin
	local y = margin
	label:setPos( x, y )
	label:setFont( self:getScheme( "fontBold" ) )

	name = "Aspect Ratio Drop-Down List"
	local aspectRatios = gui.dropdownlist( self, name )
	self.aspectRatios = aspectRatios
	aspectRatios.onValueChanged = function( dropdownlist, oldValue, newValue )
		options.aspectRatio = newValue
		self:updateResolutions()
	end
	local marginBottom = love.window.toPixels( 9 )
	y = y + label:getHeight() + marginBottom
	aspectRatios:setPos( x, y )

	name = "Resolution"
	label = gui.label( self, name, name )
	y = y + aspectRatios:getHeight() + marginBottom
	label:setPos( x, y )
	label:setFont( self:getScheme( "fontBold" ) )

	name = "Resolution Drop-Down List"
	local resolutions = gui.dropdownlist( self, name )
	self.resolutions = resolutions
	resolutions.onValueChanged = function( dropdownlist, oldValue, newValue )
		options.resolution = newValue
	end
	y = y + label:getHeight() + marginBottom
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
	y = y + aspectRatios:getHeight() + margin
	customResolution:setPos( x, y )

	name = "Width"
	local customWidth = gui.textbox( self, name, name )
	self.customWidth = customWidth
	y = y + customResolution:getHeight() + marginBottom
	customWidth:setPos( x, y )
	customWidth:setDisabled( true )
	customWidth:setDefocusOnEnter( true )
	customWidth.onLostFocus = function( textbox )
		local width = tonumber( textbox:getText() )
		if ( width == nil ) then
			return
		elseif ( width < 800 ) then
			width = 800
			textbox:setText( "800" )
		end
		options.resolution.width = width
	end

	name = "Height"
	local customHeight = gui.textbox( self, name, name )
	self.customHeight = customHeight
	y = y + customWidth:getHeight() + marginBottom
	customHeight:setPos( x, y )
	customHeight:setDisabled( true )
	customHeight:setDefocusOnEnter( true )
	customHeight.onLostFocus = function( textbox )
		local height = tonumber( textbox:getText() )
		if ( height == nil ) then
			return
		elseif ( height < 600 ) then
			height = 600
			textbox:setText( "600" )
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
	y = margin + label:getHeight() + marginBottom
	fullscreen:setPos( x, y )

	name = "Vertical Synchronization"
	local vsync = gui.checkbox( self, name, name )
	self.vsync = vsync
	options.vsync = window.vsync
	vsync:setChecked( window.vsync )
	vsync.onCheckedChanged = function( checkbox, checked )
		options.vsync = checked
		window.vsync = checked
	end
	y = y + 2 * fullscreen:getHeight() + love.window.toPixels( 4 )
	vsync:setPos( x, y )

	name = "Borderless Window"
	local borderless = gui.checkbox( self, name, name )
	self.borderless = borderless
	options.borderless = window.borderless
	borderless:setChecked( window.borderless )
	borderless.onCheckedChanged = function( checkbox, checked )
		options.borderless = checked
		window.borderless = checked
	end
	y = y + 2 * vsync:getHeight() + love.window.toPixels( 3 )
	borderless:setPos( x, y )
end

function videooptionspanel:activate()
	self:saveControlStates()
end

function videooptionspanel:clearCustomResolution()
	local customResolution = self.customResolution
	if ( customResolution == nil ) then
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
	controls.vsync            = self.vsync:isChecked()
	controls.borderless       = self.borderless:isChecked()
end

function videooptionspanel:resetControlStates()
	local controls = self.controls
	self.aspectRatios:getListItemGroup():setSelectedId( controls.aspectRatios )
	self.customResolution:setChecked( controls.customResolution )
	self.fullscreen:setChecked( controls.fullscreen )
	self.vsync:setChecked( controls.vsync )
	self.borderless:setChecked( controls.borderless )
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
		convar.setConvar( "r_window_vsync",      options.vsync      and 1 or 0 )
		convar.setConvar( "r_window_borderless", options.borderless and 1 or 0 )

		local flags  = table.copy( config.getConfig().window )
		flags.width  = nil
		flags.height = nil
		flags.icon   = nil
		love.window.setMode( resolution.width, resolution.height, flags )

		local width  = resolution.width  * love.window.getPixelScale()
		local height = resolution.height * love.window.getPixelScale()
		if ( width  == love.graphics.getWidth() and
		     height == love.graphics.getHeight() ) then
			engine.client.resize( resolution.width, resolution.height )
		end
	end
end

function videooptionspanel:updateAspectRatios()
	local supportedAspectRatios = {
		{ x = 4,   y = 3 },
		{ x = 16,  y = 9 },
	 -- { x = 683, y = 384 },
		{ x = 16,  y = 10 },
		{ x = 21,  y = 9 }
	}
	local dropdownlistitem = nil
	local name = "Aspect Ratio Drop-Down List Item"
	local text = ""
	local arx, ary = videooptionspanel.getAspectRatio()
	for i, mode in ipairs( supportedAspectRatios ) do
		local hasModes = #videooptionspanel.getFullscreenModes( mode.x, mode.y ) ~= 0
		-- HACKHACK: Include 683:384 when performing 16:9 lookups.
		if ( mode.x == 16 and mode.y == 9 and not hasModes ) then
			hasModes = #videooptionspanel.getFullscreenModes( 683, 384 ) ~= 0
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
			elseif ( options.aspectRatio == nil ) then
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
	local modes = videooptionspanel.getFullscreenModes( r.x, r.y )
	-- HACKHACK: Include 683:384 when performing 16:9 lookups.
	if ( r.x == 16 and r.y == 9 ) then
		table.append( modes, videooptionspanel.getFullscreenModes( 683, 384 ) )
		table.sort( modes, function( a, b )
			return a.width * a.height < b.width * b.height
		end )
	end
	local dropdownlistitem = nil
	local name = "Resolution Drop-Down List Item"
	local text = ""
	local foundMode = false
	local pixelScale = love.window.getPixelScale()
	local width = love.graphics.getWidth() / pixelScale
	local height = love.graphics.getHeight() / pixelScale
	for i, mode in ipairs( modes ) do
		text = mode.width .. " × " .. mode.height
		dropdownlistitem = gui.dropdownlistitem( name .. " " .. i, text )
		dropdownlistitem:setValue( mode )
		resolutions:addItem( dropdownlistitem )
		if ( mode.width == width and mode.height == height ) then
			dropdownlistitem:setDefault( true )
			foundMode = true
		end
		if ( options.resolution == nil ) then
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
