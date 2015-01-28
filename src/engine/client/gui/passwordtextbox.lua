--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Password Text Box class
--
--============================================================================--

class "passwordtextbox" ( gui.textbox )

local function getInnerWidth( self )
	return self:getWidth() - 2 * self.padding
end

function passwordtextbox:passwordtextbox( parent, name, placeholder )
	gui.textbox.textbox( self, parent, name, placeholder or "Password" )
	self.password = ""
end

local utf8sub = string.utf8sub

function passwordtextbox:doBackspace( count )
	count = count or 1

	-- Andrew; nextWord returns a position of 0 if no more words are found.
	-- Since we're backspacing a word in this case, but no word is found,
	-- backspace whatever is in front of us.
	if ( count == 0 ) then
		count = self.cursorPos + 1
	end

	if ( self.cursorPos > 0 ) then
		local sub1 = utf8sub( self.password, 1, self.cursorPos - count )
		if ( sub1 == self.password ) then
			sub1 = ""
		end

		local sub2	  = utf8sub( self.password, self.cursorPos + 1 )
		self.password = sub1 .. sub2
	end

	gui.textbox.doBackspace( self, count )
end

local utf8len = string.utf8len

function passwordtextbox:doDelete( count )
	count = count or 1

	-- Andrew; nextWord returns a position of 0 if no more words are found.
	-- Since we're deleting a word in this case, but no word is found,
	-- delete whatever is in back of us.
	if ( count == 0 ) then
		count = utf8len( self.password ) - self.cursorPos
	end

	local sub1 = utf8sub( self.password, 1, self.cursorPos )
	if ( self.cursorPos == 0 ) then
		sub1 = ""
	end

	local sub2	  = utf8sub( self.password, self.cursorPos + 1 + count )
	self.password = sub1 .. sub2
	gui.textbox.doDelete( self, count )
end

function passwordtextbox:doCut()
end

function passwordtextbox:doCopy()
end

function passwordtextbox:getAutocomplete()
end

function passwordtextbox:getPassword()
	return self.password
end

function passwordtextbox:insertText( text )
	local buffer = {}
	for i = 1, string.utf8len( text ) do
		table.insert( buffer, "•" )
	end

	local sub1 = utf8sub( self.password, self.cursorPos + 1 )
	local sub2 = utf8sub( self.password, 1, self.cursorPos )
	if ( self.cursorPos == 0 ) then
		sub2 = ""
	end

	self.password = sub2 .. text .. sub1
	gui.textbox.insertText( self, table.concat( buffer ) )
end

function passwordtextbox:isMultiline()
	return false
end

function passwordtextbox:setMultiline( multiline )
	assert( false )
end

function passwordtextbox:setText( text )
	gui.textbox.setText( self, text )
	self.password = text
end

passwordtextbox.setPassword = passwordtextbox.setText

gui.register( passwordtextbox, "passwordtextbox" )
