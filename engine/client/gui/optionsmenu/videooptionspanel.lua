--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
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
	name = name or "Video Options Panel"
	gui.frametabpanel.frametabpanel( self, parent, name )
	local options = {}
	self.options = options
	local c = config.getConfig()

	local name = "Aspect Ratio"
	local label = gui.label( self, name, name )
	local margin = 36
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
	local marginBottom = 9
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

		if ( checked ) then
			local resolution = options.resolution
			if ( resolution ) then
				local width = tonumber( customWidth:getText() )
				resolution.width = width or resolution.width

				local height = tonumber( customHeight:getText() )
				resolution.height = height or resolution.height
			end
		else
			self:updateResolutions()
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

	name = "Fullscreen Type"
	label = gui.label( self, name, name )
	x = 2 * x + resolutions:getWidth()
	y = margin
	label:setPos( x, y )
	label:setFont( self:getScheme( "fontBold" ) )

	name = "Fullscreen Types Drop-Down List"
	local fullscreentype = gui.dropdownlist( self, name )
	self.fullscreentype = fullscreentype
	local window = c.window
	options.fullscreen = window.fullscreen
	options.fullscreentype = window.fullscreentype
	fullscreentype.onValueChanged = function( dropdownlist, oldValue, newValue )
		if ( newValue ) then
			options.fullscreen     = true
			window.fullscreen      = true
			options.fullscreentype = newValue
			window.fullscreentype  = newValue
		else
			options.fullscreen     = false
			window.fullscreen      = false
			options.fullscreentype = "desktop"
			window.fullscreentype  = "desktop"
		end

		local disabled = newValue == "desktop"
		if ( disabled ) then
			customResolution:setChecked( false )
		end

		aspectRatios:setDisabled( disabled )
		resolutions:setDisabled( disabled )
		customResolution:setDisabled( disabled )
	end
	local marginBottom = 9
	y = y + label:getHeight() + marginBottom
	fullscreentype:setPos( x, y )

	for i, v in ipairs( {
		{ text = "Windowed",  mode = nil },
		{ text = "Desktop",   mode = "desktop"  },
		{ text = "Exclusive", mode = "exclusive" }
	} ) do
		local dropdownlistitem = gui.dropdownlistitem(
			fullscreentype, name .. " " .. i, v.text
		)
		dropdownlistitem:setValue( v.mode )
	end

	fullscreentype:setValue(
		window.fullscreen and window.fullscreentype or nil
	)

	name = "Vertical Synchronization"
	local vsync = gui.checkbox( self, name, name )
	self.vsync = vsync
	options.vsync = window.vsync
	vsync:setChecked( window.vsync )
	vsync.onCheckedChanged = function( checkbox, checked )
		options.vsync = checked
		window.vsync = checked
	end
	-- y = y + 2 * fullscreentype:getHeight() + 4
	y = resolutions:getY()
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
	y = y + vsync:getHeight() + marginBottom + 7
	borderless:setPos( x, y )

	name = "High-DPI"
	label = gui.label( self, name, name )
	y = customResolution:getY() + 4
	label:setPos( x, y )
	label:setFont( self:getScheme( "fontBold" ) )

	name = "High-DPI Drop-Down List"
	local highdpi = gui.dropdownlist( self, name )
	if ( love.system.getOS() == "Windows" ) then
		highdpi:setDisabled( true )
	end
	self.highdpi = highdpi
	options.highdpi = convar.getConfig( "r_window_highdpi" )
	highdpi.onValueChanged = function( dropdownlist, oldValue, newValue )
		options.highdpi = newValue
		window.highdpi = toboolean( newValue )
	end
	y = customWidth:getY()
	highdpi:setPos( x, y )

	for i, v in ipairs( {
		{ text = "Low Resolution", value = 0 },
		{ text = "Native",         value = 1 },
		{ text = "@1x",            value = 2 }
	} ) do
		local dropdownlistitem = gui.dropdownlistitem(
			highdpi, name .. " " .. i, v.text
		)
		dropdownlistitem:setValue( v.value )
	end

	highdpi:setValue( tonumber( options.highdpi ) )

	name = "High-DPI Label"
	local text = "Changing high-DPI requires restarting the game."
	label = gui.label( self, name, text )
	local marginTop = marginBottom
	y = y + highdpi:getHeight() + marginTop
	label:setPos( x, y )
	local font = self:getScheme( "fontSmall" )
	label:setFont( font )
	label:setWidth( font:getWidth( text ) )
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
	controls.fullscreentype   = self.fullscreentype:getValue()
	controls.vsync            = self.vsync:isChecked()
	controls.borderless       = self.borderless:isChecked()
	controls.highdpi          = self.highdpi:getValue()
end

function videooptionspanel:resetControlStates()
	local controls = self.controls
	self.aspectRatios:getListItemGroup():setSelectedId( controls.aspectRatios )
	self.customResolution:setChecked( controls.customResolution )
	self.fullscreentype:setValue( controls.fullscreentype )
	self.vsync:setChecked( controls.vsync )
	self.borderless:setChecked( controls.borderless )
	self.highdpi:setValue( controls.highdpi )
	table.clear( controls )

	self:clearCustomResolution()
end

function videooptionspanel:updateMode()
	local options    = self.options
	local resolution = options.resolution
	if ( resolution == nil ) then
		return
	end

	convar.setConvar( "r_window_width",          resolution.width )
	convar.setConvar( "r_window_height",         resolution.height )
	convar.setConvar( "r_window_fullscreen",     options.fullscreen and 1 or 0 )
	convar.setConvar( "r_window_fullscreentype", options.fullscreentype )
	convar.setConvar( "r_window_vsync",          options.vsync      and 1 or 0 )
	convar.setConvar( "r_window_borderless",     options.borderless and 1 or 0 )
	convar.setConvar( "r_window_highdpi",        options.highdpi )

	local flags  = table.copy( config.getConfig().window )
	flags.width  = nil
	flags.height = nil
	flags.icon   = nil
	love.window.setMode( resolution.width, resolution.height, flags )

	local rw, rh = resolution.width, resolution.height
	local ww, wh = love.window.getMode()
	if ( rw == ww and rh == wh ) then
		engine.client.resize( resolution.width, resolution.height )
		self:updateResolutions()
	end
end

function videooptionspanel:updateAspectRatios()
	local supportedAspectRatios = {
		{ x = 4,   y = 3 },
		{ x = 16,  y = 9 },
	 -- See https://en.wikipedia.org/wiki/Graphics_display_resolution
	 -- #WXGA_.281366x768_and_similar.29
	 -- { x = 683, y = 384 },
		{ x = 16,  y = 10 },
		{ x = 21,  y = 9 }
	}
	local dropdownlistitem = nil
	local name = "Aspect Ratio Drop-Down List Item"
	local text = ""
	local arx, ary = videooptionspanel.getAspectRatio()
	for i, mode in ipairs( supportedAspectRatios ) do
		local hasModes = #videooptionspanel.getFullscreenModes(
			mode.x, mode.y
		) ~= 0
		-- Include 683:384 when performing 16:9 lookups.
		if ( mode.x == 16 and mode.y == 9 and not hasModes ) then
			hasModes = #videooptionspanel.getFullscreenModes( 683, 384 ) ~= 0
		end

		if ( hasModes ) then
			text = mode.x .. ":" .. mode.y
			dropdownlistitem = gui.dropdownlistitem(
				self.aspectRatios, name .. " " .. i, text
			)
			dropdownlistitem:setValue( mode )
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
	-- Include 683:384 when performing 16:9 lookups.
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
	local scale = love.window.getDPIScale()
	local width = love.graphics.getWidth() / scale
	local height = love.graphics.getHeight() / scale
	for i, mode in ipairs( modes ) do
		text = scale > 1 and "Looks like " or ""
		text = text .. mode.width .. " × " .. mode.height
		dropdownlistitem = gui.dropdownlistitem(
			resolutions, name .. " " .. i, text
		)
		dropdownlistitem:setValue( mode )
		if ( mode.width == width and mode.height == height ) then
			dropdownlistitem:setDefault( true )
			foundMode = true
		end
		if ( options.resolution == nil ) then
			options.resolution = mode
		end
	end

	if ( not foundMode ) then
		local scale = love.graphics.getDPIScale()
		self.customWidth:setText( tostring( scale * width ) )
		self.customHeight:setText( tostring( scale * height ) )
	else
		self:clearCustomResolution()
	end
end
