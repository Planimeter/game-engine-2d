--=========== Copyright © 2019, Planimeter, All rights reserved. ===========--
--
-- Purpose: Game Menu Navigation class
--
--==========================================================================--

class "gui.hudgamemenunavigation" ( "gui.radiobuttongroup" )

local hudgamemenunavigation = gui.hudgamemenunavigation

function hudgamemenunavigation:hudgamemenunavigation( parent )
	gui.radiobuttongroup.radiobuttongroup( self, parent, "Game Menu Navigation" )
	self:setScheme( "Default" )

	self.tabs = {
		"Inventory",
		"Stats"
	}

	for _, name in ipairs( self.tabs ) do
		local item = gui.hudgamemenunavigationbutton( self, name )
		self:addItem( item )
	end
end

function hudgamemenunavigation:addItem( item, default )
	item:setParent( self )
	gui.radiobuttongroup.addItem( self, item )

	if ( default or #self:getItems() == 1 ) then
		item:setDefault( true )
	end

	self:invalidateLayout()
end

function hudgamemenunavigation:draw()
	gui.box.draw( self )

	local property  = "hudgamemenunavigation.backgroundColor"
	local lineWidth = 1
	local width     = self:getWidth()
	love.graphics.setColor( self:getScheme( property ) )
	love.graphics.setLineStyle( "rough" )
	love.graphics.setLineWidth( lineWidth )
	love.graphics.line(
		0,     lineWidth / 2, -- Top-left
		width, lineWidth / 2  -- Top-right
	)
end

function hudgamemenunavigation:invalidateLayout()
	local listItems = self:getItems()
	if ( listItems ) then
		local x = 0
		for _, listItem in ipairs( listItems ) do
			listItem:setX( x )
			x = x + listItem:getWidth() + 18
		end
	end
	gui.panel.invalidateLayout( self )
end

function hudgamemenunavigation:onValueChanged( oldValue, newValue )
	local parent = self:getParent()
	for _, name in ipairs( self.tabs ) do
		name = string.lower( name )
		parent[ name ]:setVisible( false )
	end

	if ( newValue ) then
		local panel = parent[ string.lower( newValue ) ]
		panel:setVisible( true )
		panel:invalidateLayout()
	end
end
