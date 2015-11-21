--========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========--
--
-- Purpose: Game Menu Navigation class
--
--============================================================================--

class "hudgamemenunavigation" ( gui.radiobuttongroup )

function hudgamemenunavigation:hudgamemenunavigation( parent )
	gui.radiobuttongroup.radiobuttongroup( self, parent, "Game Menu Navigation" )
	self:setScheme( "Default" )

	self.tabs = {
		"Inventory",
		-- "Prayer",
		-- "Spells",
		-- "Stats",
		-- "Quests"
	}

	for _, name in ipairs( self.tabs ) do
		local item = gui.hudgamemenunavigationbutton( self, name )
		if ( name ~= "Inventory" ) then
			item:setDisabled( true )
		end

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
	gui.panel.draw( self )

	local property = "hudgamemenunavigation.backgroundColor"
	local width    = self:getWidth()
	graphics.setColor( self:getScheme( property ) )
	graphics.line( 0, 0, width, 0 )
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
end

function hudgamemenunavigation:onValueChanged( oldValue, newValue )
	local parent = self:getParent()
	for _, name in ipairs( self.tabs ) do
		name = string.lower( name )
		parent[ name ]:setVisible( false )
	end

	if ( newValue ) then
		parent[ string.lower( newValue ) ]:setVisible( true )
	end
end

gui.register( hudgamemenunavigation, "hudgamemenunavigation" )
