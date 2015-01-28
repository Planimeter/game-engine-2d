--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Frame Tab Panels class
--
--============================================================================--

class "frametabpanels" ( gui.panel )

function frametabpanels:frametabpanels( parent, name, text )
	gui.panel.panel( self, parent, name )
	self.width	= parent:getWidth()
	self.height = parent:getHeight() - 62
end

function frametabpanels:addPanel( frametabpanel, default )
	frametabpanel:setSize( self:getSize() )
	frametabpanel:setParent( self )

	if ( not default and #self:getChildren() ~= 1 ) then
		frametabpanel:setVisible( false )
	end
end

function frametabpanels:setSelectedChild( i )
	for j, v in ipairs( self:getChildren() ) do
		v:setVisible( i == j )
		v:invalidate()
	end
end

gui.register( frametabpanels, "frametabpanels" )
