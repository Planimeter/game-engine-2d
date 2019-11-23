--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Frame Tab Panels class
--
--==========================================================================--

class "gui.frametabpanels" ( "gui.box" )

local frametabpanels = gui.frametabpanels

function frametabpanels:frametabpanels( parent, name, text )
	gui.box.box( self, parent, name )
	self:setDisplay( "block" )
	self:setPosition( "absolute" )
	self.width	= parent:getWidth()
	self.height = parent:getHeight() - 62
end

function frametabpanels:addPanel( frametabpanel, default )
	local panel = frametabpanel( self )
	panel:setDimensions( self:getDimensions() )

	if ( not default and #self:getChildren() ~= 1 ) then
		panel:setVisible( false )
	end

	return panel
end

function frametabpanels:setSelectedChild( i )
	for j, v in ipairs( self:getChildren() ) do
		v:setVisible( i == j )
		v:invalidate()
	end
end
