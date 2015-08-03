--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Options Item Group class
--
--============================================================================--

class "optionsitemgroup" ( gui.dropdownlistitemgroup )

function optionsitemgroup:optionsitemgroup( parent, name )
	gui.dropdownlistitemgroup.dropdownlistitemgroup( self, parent, name )
	-- UNDONE: The drop-down list field is reserved for the control responsible
	-- for the drop-down list item group. The control does not necessarily have
	-- to be a dropdownlist.
	-- self.dropDownList = nil

	self:setSuppressFramebufferWarnings( true )
end

gui.register( optionsitemgroup, "optionsitemgroup" )
