--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Text Box class
--
--============================================================================--

class "textbox" ( gui.panel )

textbox.maskedTextbox = textbox.maskedTextbox or nil
textbox.canFocus	  = true

local function getInnerWidth( self )
	return self:getWidth() - 2 * self.padding
end

local function getInnerHeight( self )
	return self:getHeight() - 2 * self.padding
end

function textbox.drawMask()
	local self = gui.textbox.maskedTextbox
	graphics.rectangle( "fill",
						self.padding,
						0,
						getInnerWidth( self ),
						self:getHeight() )
end

function textbox:textbox( parent, name, placeholder )
	gui.panel.panel( self, parent, name )
	self.width			= 216
	self.height			= 46
	self.focus			= false
	self.defocusOnEnter = false
	self.placeholder	= placeholder or "Text Box"
	self.text			= ""
	self.padding		= 18
	self.cursorPos		= 0
	self.textOverflow	= 0
	self.scrollOffset	= 0
	self.disabled		= false
	self.editable		= true
	self.multiline		= false

	self:setScheme( "Default" )
	self:setUseFullscreenFramebuffer( true )
end

function textbox:draw()
	if ( not self:isVisible() ) then
		return
	end

	self:drawText()
	self:drawCursor()

	gui.panel.draw( self )

	self:drawForeground()
end

local function getTextX( self )
	return self.padding - self.textOverflow - self.scrollOffset
end

local function getTextY( self )
	if ( self:isMultiline() ) then
		return self.padding - ( self.scrollbar and self.scrollbar:getValue() or
												   self.padding )
	else
		local font = self:getScheme( "font" )
		return self:getHeight() / 2 - font:getHeight() / 2 - 2
	end
end

local utf8sub = string.utf8sub

local function getRelativeCursorPos( self )
	local font = self:getScheme( "font" )
	local x	   = getTextX( self )
	if ( self.cursorPos > 0 ) then
		x = x + font:getWidth( utf8sub( self.text, 1, self.cursorPos ) )
	end

	if ( x > self:getWidth() - self.padding ) then
		local pos = self:getWidth() - self.padding
		return pos, x - pos
	elseif ( x < self.padding ) then
		return self.padding, x - self.padding
	else
		return x
	end
end

local abs = math.abs
local sin = math.sin

function textbox:drawCursor()
	if ( not self:isEditable() ) then
		return
	end

	local font = self:getScheme( "font" )
	if ( self.focus ) then
		local opacity = graphics.getOpacity()
		graphics.setOpacity( opacity * abs( sin( 3 * engine.getRealTime() ) ) )
		graphics.setColor( graphics.getColor() )
			graphics.rectangle( "fill",
								getRelativeCursorPos( self ),
								self:getHeight() / 2 - font:getHeight() / 2,
								1,
								font:getHeight() )
		graphics.setOpacity( opacity )
	end
end

function textbox:drawForeground()
	local property = "textbox.outlineColor"
	local width	   = self:getWidth()
	local height   = self:getHeight()

	if ( self:isEditable() ) then
		local selected = self.mousedown or self.mouseover
		if ( self.focus ) then
			property = "textbox.focus.outlineColor"
		elseif ( selected and not self:isDisabled() ) then
			property = "textbox.mouseover.outlineColor"
		end
	end

	graphics.setColor( self:getScheme( property ) )
	graphics.setLineWidth( 1 )
	graphics.rectangle( "line", 0, 0, width, height )
end

function textbox:drawText()
	gui.textbox.maskedTextbox = self
	graphics.setStencil( gui.textbox.drawMask )
		local property = "textbox.textColor"
		local text	   = self.placeholder

		local selected = self.mousedown or self.mouseover
		if ( self.focus or self.text ~= "" ) then
			property = "textbox.focus.textColor"
			text	 = self.text
		elseif ( selected and not self:isDisabled() ) then
			property = "textbox.mouseover.textColor"
		end

		if ( self:isDisabled() ) then
			property = "textbox.disabled.textColor"
			if ( self.text ~= "" ) then
				text = self.text
			end
		end

		graphics.setColor( self:getScheme( property ) )

		local font = self:getScheme( "font" )
		graphics.setFont( font )
		local x = getTextX( self )
		local y = getTextY( self )
		if ( not self:isMultiline() ) then
			graphics.print( text, x, y )
		else
			graphics.printf( text, x, y, self:getWidth() - 2 * self.padding )
		end
	graphics.setStencil()
end

local function getTextWidth( self )
	local font = self:getScheme( "font" )
	return font:getWidth( self.text )
end

local function getTextHeight( self )
	local font		   = self:getScheme( "font" )
	local width, lines = font:getWrap( self.text, getInnerWidth( self ) )
	return lines * font:getHeight()
end

local function isTextOverflowing( self )
	return getTextWidth( self ) > getInnerWidth( self )
end

local resetScrollOffset = false

local function updateOverflow( self )
	if ( isTextOverflowing( self ) and not self:isMultiline() ) then
		self.textOverflow = getTextWidth( self ) - getInnerWidth( self )
	else
		self.textOverflow = 0
		self.scrollOffset = 0
	end
end

local function updateAutocomplete( self, suggestions )
	if ( self.autocompleteItemGroup:getChildren() ) then
		self.autocompleteItemGroup:removeChildren()
	end

	if ( not suggestions ) then
		return
	end

	local dropdownlistitem = nil
	local name			   = "Autocomplete Drop-Down List Item"
	for i, suggestion in pairs( suggestions ) do
		dropdownlistitem = gui.dropdownlistitem( name .. " " .. i, suggestion )
		dropdownlistitem:setValue( suggestion )
		self.autocompleteItemGroup:addItem( dropdownlistitem )
	end
end

function textbox:doBackspace( count )
	count = count or 1

	-- Andrew; nextWord returns a position of 0 if no more words are found.
	-- Since we're backspacing a word in this case, but no word is found,
	-- backspace whatever is in front of us.
	if ( count == 0 ) then
		count = self.cursorPos + 1
	end

	if ( self.cursorPos > 0 ) then
		local sub1 = utf8sub( self.text, 1, self.cursorPos - count )
		if ( sub1 == self.text ) then
			sub1 = ""
		end

		local text = utf8sub( self.text, self.cursorPos + 1 - count, self.cursorPos )
		local font = self:getScheme( "font" )
		if ( isTextOverflowing( self ) ) then
			self.scrollOffset = self.scrollOffset + font:getWidth( text )
			local pos, offset = getRelativeCursorPos( self )
			if ( offset ) then
				self.scrollOffset = self.scrollOffset -
									getInnerWidth( self ) +
									offset
				if ( getTextX( self ) > 0 ) then
					resetScrollOffset = true
				end
			end
		end

		local sub2	   = utf8sub( self.text, self.cursorPos + 1 )
		self.text	   = sub1 .. sub2
		self.cursorPos = math.max( 0, self.cursorPos - count )
	end

	updateOverflow( self )

	local autocomplete = self:getAutocomplete()
	if ( autocomplete ) then
		updateAutocomplete( self, autocomplete( self:getText() ) )
	end

	if ( resetScrollOffset ) then
		self.scrollOffset = -self.textOverflow
		resetScrollOffset = false
	end

	self:onChange()
end

local utf8len = string.utf8len

function textbox:doDelete( count )
	count = count or 1

	-- Andrew; nextWord returns a position of 0 if no more words are found.
	-- Since we're deleting a word in this case, but no word is found,
	-- delete whatever is in back of us.
	if ( count == 0 ) then
		count = utf8len( self.text ) - self.cursorPos
	end

	local sub1 = utf8sub( self.text, 1, self.cursorPos )
	if ( self.cursorPos == 0 ) then
		sub1 = ""
	end

	local text = utf8sub( self.text, self.cursorPos + 1, self.cursorPos + count )
	if ( self.cursorPos == utf8len( self.text ) ) then
		text = ""
	end
	local font = self:getScheme( "font" )
	if ( self.cursorPos ~= utf8len( self.text ) and
		 isTextOverflowing( self ) ) then
		self.scrollOffset = self.scrollOffset + font:getWidth( text )
	end

	local sub2 = utf8sub( self.text, self.cursorPos + 1 + count )
	self.text  = sub1 .. sub2
	updateOverflow( self )

	self:onChange()
end

function textbox:doCut()
end

function textbox:doCopy()
end

local gsub = string.gsub

local function doPaste( self )
	local clipboardText = os.getClipboardText()
	if ( not clipboardText ) then
		return
	end

	if ( not self:isMultiline() ) then
		clipboardText = gsub( clipboardText, "\n", "" )
	end

	self:insertText( clipboardText )
end

local function doSelectAll( self )
end

function textbox:getAutocomplete()
	return self.autocomplete
end

function textbox:getDefocusOnEnter()
	return self.defocusOnEnter
end

function textbox:getPlaceholder()
	return self.placeholder
end

function textbox:getText()
	return self.text
end

local function updateScrollbarRange( self )
	local textHeight = getTextHeight( self ) + 2 * self.padding
	if ( textHeight > getInnerHeight( self ) + 2 * self.padding ) then
		self.scrollbar:setRange( 0, textHeight )
		self.scrollbar:setRangeWindow( self:getHeight() )
	else
		self.scrollbar:setRange( 0, 0 )
		self.scrollbar:setRangeWindow( 0 )
	end
end

function textbox:insertText( text )
	local underflow = getTextWidth( self ) < getInnerWidth( self )
	local font		= self:getScheme( "font" )
	local sub1		= utf8sub( self.text, self.cursorPos + 1 )
	local sub2		= utf8sub( self.text, 1, self.cursorPos )
	if ( self.cursorPos == 0 ) then
		sub2 = ""
	end

	if ( getTextWidth( self ) + font:getWidth( text ) >
		 getInnerWidth( self ) ) then
		self.scrollOffset	= self.scrollOffset - font:getWidth( text )
		local pos, overflow	= getRelativeCursorPos( self )
		if ( overflow ) then
			self.scrollOffset = self.scrollOffset + overflow
		end
		if ( underflow and getTextX( self ) > 0 ) then
			resetScrollOffset = true
		end
	end

	self.text = sub2 .. text .. sub1
	updateOverflow( self )
	if ( resetScrollOffset ) then
		self.scrollOffset = 0
		underflow		  = false
		resetScrollOffset = false
	end
	self.cursorPos = self.cursorPos + utf8len( text )

	local autocomplete = self:getAutocomplete()
	if ( autocomplete ) then
		updateAutocomplete( self, autocomplete( self:getText() ) )
	end

	if ( self:isMultiline() ) then
		updateScrollbarRange( self )
		self.scrollbar:scrollToBottom()
	end

	self:invalidate()
	self:onChange()
end

function textbox:invalidateLayout()
	if ( self.autocompleteItemGroup ) then
		self.autocompleteItemGroup:invalidateLayout()
	end

	if ( self.scrollbar ) then
		updateScrollbarRange( self )
	end

	gui.panel.invalidateLayout( self )
end

function textbox:isDisabled()
	return self.disabled
end

function textbox:isEditable()
	return self.editable
end

function textbox:isMultiline()
	return self.multiline
end

local function updateScrollOffset( self )
	local pos, overflow = getRelativeCursorPos( self )
	if ( overflow ) then
		self.scrollOffset = self.scrollOffset + overflow
	end
end

local function shiftCursor( self, pos )
	self.cursorPos = math.clamp( self.cursorPos + pos,
								 0,
								 utf8len( self.text ) )
	updateScrollOffset( self )
end

local utf8reverse = string.utf8reverse
local find		  = string.find

local function nextWord( self, dir )
	local backwards	 = dir == -1
	local startPos	 = backwards and 1				or self.cursorPos + 1
	local endPos	 = backwards and self.cursorPos or nil
	local sub		 = utf8sub( self.text, startPos, endPos )
	if ( backwards ) then
		sub			 = utf8reverse( sub )
	end
	startPos, endPos = find( sub, "%s*." )
	local pos		 = 0
	if ( startPos == 1 ) then
		sub			 = utf8sub( sub, endPos )
		pos			 = endPos - 1
	end
	startPos, endPos = find( sub, ".-%s" )
	if ( backwards ) then
		if ( endPos ) then
			pos = -endPos + 1 - pos
			sub = utf8sub( sub, startPos, startPos + 1 )
			if ( find( sub, "^%s$" ) ) then
				pos = pos - 1
			end
			return pos
		else
			return 0
		end
	else
		if ( startPos == 1 ) then
			sub = utf8sub( sub, endPos )
			pos = pos + endPos - 1
		end
		startPos, endPos = find( sub, "%s*." )
		if ( startPos == 1 ) then
			sub = utf8sub( sub, endPos )
			pos = pos + endPos - 1
			if ( find( sub, "^%s$" ) ) then
				pos = pos + 1
			end
		end
		return pos
	end
end

local function selectSuggestion( self, dir )
	if ( not self.autocompleteItemGroup:getChildren() ) then
		return
	end

	local backwards	 = dir == -1
	local selectedId = self.autocompleteItemGroup:getSelectedId()
	local items		 = #self.autocompleteItemGroup:getItems()
	selectedId		 = selectedId + ( backwards and -1 or 1 )
	if ( backwards ) then
		selectedId	 = math.clamp( selectedId, 0, items )
	else
		selectedId	 = math.clamp( selectedId, 1, items + 1 )
	end
	if ( selectedId == ( backwards and 0 or items + 1 ) ) then
		self.autocompleteItemGroup:setSelectedId( backwards and items or 1 )
	else
		self.autocompleteItemGroup:setSelectedId( selectedId )
	end
end

function textbox:keypressed( key, isrepeat )
	if ( not self:isVisible() or not self.focus or not self:isEditable() ) then
		return
	end

	local controlDown = input.isKeyDown( "lctrl", "rctrl" )
	local shiftDown	  = input.isKeyDown( "lshift", "rshift" )
	if ( key == "backspace" ) then
		self:doBackspace( controlDown and math.abs( nextWord( self, -1 ) ) or 1 )
	elseif ( key == "delete" ) then
		self:doDelete( controlDown and nextWord( self, 1 ) or 1 )
	elseif ( key == "end" ) then
		if ( getTextWidth( self ) + getTextX( self ) >
			 getInnerWidth( self ) ) then
			self.scrollOffset = 0
		end
		self.cursorPos = utf8len( self.text )
	elseif ( key == "home" ) then
		self.scrollOffset = -self.textOverflow
		self.cursorPos	  = 0
	elseif ( key == "left" ) then
		if ( not controlDown ) then
			shiftCursor( self, -1 )
		else
			local pos = nextWord( self, -1 )
			if ( pos ~= 0 ) then
				shiftCursor( self, pos )
			else
				self.scrollOffset = -self.textOverflow
				self.cursorPos	  = 0
			end
		end
	elseif ( key == "right" ) then
		if ( not controlDown ) then
			shiftCursor( self, 1 )
		else
			local pos = nextWord( self, 1 )
			if ( pos ~= 0 ) then
				shiftCursor( self, pos )
			else
				if ( getTextWidth( self ) + getTextX( self ) >
					 getInnerWidth( self ) ) then
					self.scrollOffset = 0
				end
				self.cursorPos = utf8len( self.text )
			end
		end
	elseif ( key == "up"   and self.autocompleteItemGroup ) then
		selectSuggestion( self, -1 )
	elseif ( key == "down" and self.autocompleteItemGroup ) then
		selectSuggestion( self, 1 )
	elseif ( key == "tab"  and self.autocompleteItemGroup ) then
		if ( not shiftDown ) then
			selectSuggestion( self, 1 )
		else
			selectSuggestion( self, -1 )
		end
	elseif ( key == "return"
		  or key == "kpenter" ) then
		if ( not self:isMultiline() ) then
			if ( self.autocompleteItemGroup and
				 self.autocompleteItemGroup:getSelectedItem() ) then
				self.autocompleteItemGroup:getSelectedItem():onClick()
				return
			end

			self:onEnter( self.text )
			if ( self:getDefocusOnEnter() ) then
				if ( self.focus ) then
					gui.setFocusedPanel( self, false )
				end
			end
		end
	elseif ( controlDown ) then
		if ( key == "a" ) then
			doSelectAll( self )
		elseif ( key == "x" ) then
			self:doCut( self )
		elseif ( key == "c" ) then
			self:doCopy( self )
		elseif ( key == "v" ) then
			doPaste( self )
		end
	end

	return true
end

function textbox:keyreleased( key )
	if ( not self:isVisible() or not self.focus or not self:isEditable() ) then
		return
	end

	return true
end

local posX, posY = 0, 0

local function parentFrameHasFocus( self )
	local parent = self:getParent()
	while ( parent ~= nil ) do
		if ( typeof( parent, "frame" ) ) then
			return parent.focus == true
		end
		parent = parent:getParent()
	end
	return false
end

local function isChildMousedOver( self )
	local panel = gui.topPanel
	while ( panel ~= nil ) do
		panel = panel:getParent()
		if ( panel and panel == self.autocompleteItemGroup ) then
			return true
		end
	end

	return false
end

function textbox:mousepressed( x, y, button )
	if ( not self:isVisible() ) then
		return
	end

	if ( self.mouseover and not self:isDisabled() ) then
		posX, posY = self:screenToLocal( x, y )
		if ( button == "l" ) then
			self.mousedown = true
			self:onClick( posX, posY )
		elseif ( button == "r" ) then
			self.mousedown = true
			-- TODO: Implement gui.contextmenu!!
			-- self:openContextMenu( posX, posY )
		elseif ( button == "wd" and parentFrameHasFocus( self ) ) then
			if ( self.scrollbar ) then
				local font = self:getScheme( "font" )
				self.scrollbar:scrollDown( 3 * font:getHeight() )
			end
		elseif ( button == "wu" and parentFrameHasFocus( self ) ) then
			if ( self.scrollbar ) then
				local font = self:getScheme( "font" )
				self.scrollbar:scrollUp( 3 * font:getHeight() )
			end
		end
	else
		local mousewheelPressed = button == "wd" or button == "wu"
		if ( self.focus			   and
			 not mousewheelPressed and
			 not isChildMousedOver( self ) ) then
			gui.setFocusedPanel( self, false )
		end
	end

	gui.panel.mousepressed( self, x, y, button )
end

function textbox:mousereleased( x, y, button )
	if ( not self:isVisible() ) then
		return
	end

	self.mousedown = false

	gui.panel.mousereleased( self, x, y, button )
end

function textbox:onChange( text )
end

function textbox:onClick( x, y )
	x = x - getTextX( self )

	if ( not self.focus ) then
		gui.setFocusedPanel( self, true )
	end

	if ( self:isEditable() ) then
		local font = self:getScheme( "font" )
		if ( x <= 0 ) then
			self.cursorPos = 0
		elseif ( x >= getTextWidth( self ) ) then
			self.cursorPos = utf8len( self.text )
		else
			for i = 1, utf8len( self.text ) do
				local width	   = font:getWidth( utf8sub( self.text, 1, i ) )
				local startPos = i == 1 and 0 or width
				width		 = font:getWidth( utf8sub( self.text, 1, i + 1 ) )
				local endPos = width

				if ( x > startPos and x < endPos ) then
					local midpoint = ( startPos + endPos ) / 2
					if ( x > midpoint ) then
						self.cursorPos = i + 1
					else
						self.cursorPos = i
					end

					break
				end
			end
		end

		if ( self.autocompleteItemGroup ) then
			self.autocompleteItemGroup:updatePos()
		end
	end
end

function textbox:onEnter( text )
end

function textbox:onFocus()
	input.setTextInput( true )
	input.setKeyRepeat( true )
end

function textbox:onLostFocus()
	input.setTextInput( false )
	input.setKeyRepeat( false )
end

function textbox:onMouseLeave()
	os.setCursor()
end

function textbox:setAutocomplete( autocomplete )
	self.autocomplete = autocomplete
	if ( autocomplete ) then
		local name = self.name .. " Autocomplete Item Group"
		self.autocompleteItemGroup = gui.textboxautocompleteitemgroup( self, name )
	else
		if ( self.autocompleteItemGroup ) then
			self.autocompleteItemGroup:remove()
			self.autocompleteItemGroup = nil
		end
	end
end

function textbox:setDefocusOnEnter( defocus )
	self.defocusOnEnter = defocus
end

function textbox:setDisabled( disabled )
	self.disabled = disabled
	self.canFocus = not disabled

	if ( disabled ) then
		gui.setFocusedPanel( self, false )
	end

	self:invalidate()
end

function textbox:setEditable( editable )
	self.editable = editable
	self.canFocus = editable
end

function textbox:setMultiline( multiline )
	self.multiline = multiline
	if ( multiline ) then
		self.scrollbar = gui.scrollbar( self, self:getName() .. " Scrollbar" )
	else
		if ( self.scrollbar ) then
			self.scrollbar:remove()
			self.scrollbar = nil
		end
	end
end

function textbox:setPlaceholder( placeholder )
	self.placeholder = placeholder
end

function textbox:setText( text )
	self.text	   = text
	self.cursorPos = utf8len( text )

	local autocomplete = self:getAutocomplete()
	if ( autocomplete ) then
		updateAutocomplete( self, autocomplete( self:getText() ) )
	end

	if ( self.scrollbar ) then
		updateScrollbarRange( self )
	end

	self:invalidate()
	self:onChange()
end

function textbox:setWidth( width )
	gui.panel.setWidth( self, width )
	if ( self.scrollbar ) then
		updateScrollbarRange( self )
	end
end

function textbox:setHeight( height )
	gui.panel.setHeight( self, height )
	if ( self.scrollbar ) then
		updateScrollbarRange( self )
	end
end

function textbox:textinput( text )
	if ( not self:isVisible() or not self.focus or not self:isEditable() ) then
		return
	end

	self:insertText( text )
	return true
end

local function updateCursor( self )
	if ( not self.mouseover or self:isDisabled() ) then
		return
	end

	os.setCursor( "ibeam" )
end

function textbox:update()
	updateCursor( self )

	if ( self.focus ) then
		self:invalidate()
	end

	gui.panel.update( self )
end

gui.register( textbox, "textbox" )
