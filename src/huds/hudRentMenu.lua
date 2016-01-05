-- Copyright (C) 2015 mInternauta

-- This program is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; either version 2
-- of the License, or (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
AgroRentMenuHud = {};

source(AgroSponsor.ModInstallDir .. 'huds/hudComboBox.lua')

-- Initialize the Menu
function AgroRentMenuHud:init() 	
	-- Overlays
	self.backOverlay = createImageOverlay(Utils.getFilename('img/rentMenu.png', AgroSponsor.ModInstallDir));
	self.backItemOverlay = createImageOverlay(Utils.getFilename('img/rentItemBack.png', AgroSponsor.ModInstallDir));
	self.spoOverlay = createImageOverlay(Utils.getFilename('img/sponsored.png', AgroSponsor.ModInstallDir));

	-- Categories ComboBox
	self.cbCategories = createComboBox(0.21,0.70);
	
	-- Items ComboBox
	self.cbItems = createComboBox(0.40,0.70);
	
	-- Build the Categories List 
	for catId, cat in pairs(StoreItemsUtil.storeCategories) do 
		-- Exclude Sales, Animals and Placeables store items from the list
		if cat["name"] ~= "sales" and cat["name"] ~= "animals" and cat["name"] ~= "placeables" then 
			self.cbCategories:add(catId, cat["title"]);
		end 
	end 
	
	-- Bind Events
	self.cbCategories:bindOnChange('rentCatChange', AgroRentMenuHud.onCategoryChangeEvent);
	self.cbItems:bindOnChange('rentItemChange', AgroRentMenuHud.onItemChangeEvent);
	
	-- Pre execute the events
	self:onCategoryChange();
	self:onItemChange();
	
	-- set default visibility
	self.visible = false;
	self.myTitle = as.utils.getText('AGROSPONSOR_RENTTITLE');
end 

function AgroRentMenuHud:onCategoryChangeEvent()
	AgroRentMenuHud:onCategoryChange();
	AgroRentMenuHud:onItemChange();
end 

function AgroRentMenuHud:onCategoryChange()
	self.cbItems:clear();
	
	for itemID, item in pairs(StoreItemsUtil.storeItems) do 
		local itemCat = item["category"];
		local selCat = self.cbCategories:getSelected();
		if selCat == itemCat then 			
			self.cbItems:add(itemID, item["name"]);
		end 
	end 
end 

function AgroRentMenuHud:onItemChangeEvent()
	AgroRentMenuHud:onItemChange();
end 

function AgroRentMenuHud:onItemChange()
	local id = self.cbItems:getSelected();
	self.selectedItem = AgroRentManager:create(id);
	
	self.curImgOverlay = createImageOverlay(self.selectedItem['Store']['imageActive']);
	
--	as.utils.print_r(self.selectedItem);
end 

function AgroRentMenuHud:show()
	self.visible = true;
	self.cbCategories:show();
	self.cbItems:show();
end 

function AgroRentMenuHud:hide()
	self.visible = false;
	
	self.cbCategories:hide();
	self.cbItems:hide();
	
	-- DISABLE the mouse 
	asMouseHud:setEnabled(false);
end 

function AgroRentMenuHud:update(dt) 	 
	self.cbCategories:update();
	self.cbItems:update();
end 

function AgroRentMenuHud:draw()
	if self.visible then 
		-- Render the overlay
		renderOverlay(self.backOverlay, 0.2, 0.2, 0.62, 0.63);			
				
		-- Render the title
		renderText(0.205, 0.795, 0.022, self.myTitle);
		
		setTextColor(0,0,0, 1);
		setTextBold(true);
		
		renderText(0.21, 0.745, 0.018, as.utils.getText('AGROSPONSOR_RENTBRAND'));
		renderText(0.40, 0.745, 0.018, as.utils.getText('AGROSPONSOR_RENTEQ'));
		
		setTextColor(1,1,1, 1);
		setTextBold(false);
		
		-- QUIT
		renderText(0.205, 0.21, 0.018, as.utils.getText('AGROSPONSOR_EXITKEY'));
		
		-- Exp Tip
		renderText(0.631, 0.22, 0.018, as.utils.getText('AGROSPONSOR_RENTEXPTIP'));
		
		-- Price Tip
		renderText(0.461, 0.22, 0.018, as.utils.getText('AGROSPONSOR_RENTPRICETIP'));
		
		-- ComboBox
		self.cbCategories:draw();
		self.cbItems:draw();
		
		if self.selectedItem ~= nil then 
			-- Render the items overlay		
			renderOverlay(self.backItemOverlay, 0.3, 0.26, 0.44, 0.40);
			renderOverlay(self.curImgOverlay, 0.32, 0.382, 0.16, 0.20);
			
			-- Render the Prize
			renderText(0.36, 0.305, 0.022, as.utils.toMoneyString(self.selectedItem['Price']));
			
			-- Render the Experience points
			renderText(0.46, 0.305, 0.022, tostring(self.selectedItem['Exp']));
			
			-- Render the sponsored icon 
			if self.selectedItem['IsSponsored'] then 				
				renderOverlay(self.spoOverlay, 0.45, 0.362, 0.028, 0.04);
				
				setTextColor(0.8,0,0, 1)
				renderText(0.6, 0.585, 0.020, 'Sponsored');
				setTextColor(1,1,1, 1)
			end 
			
			-- Render the brand and the name 
			setTextColor(0,0,0, 1);
			renderText(0.5, 0.605, 0.028, self.selectedItem['Store']['brand']);
			renderText(0.5, 0.585, 0.022, self.selectedItem['Store']['name']);
						
			-- Render the equipament specs
			
			
			setTextColor(1,1,1, 1);
		end 
		
		-- Enable the mouse 
		asMouseHud:setEnabled(true);
	end
end 

function AgroRentMenuHud:deleteMap()	
end;

function AgroRentMenuHud:loadMap(name)
end;

function AgroRentMenuHud:keyEvent(unicode, sym, modifier, isDown)
	if sym == Input.KEY_q and isDown == true and self.visible then
		self:hide();
	end;
end;

function AgroRentMenuHud:mouseEvent(posX, posY, isDown, isUp, button)
	if isDown then 
		self.cbCategories:onMouseDown();
		self.cbItems:onMouseDown();
	end 
end;

addModEventListener(AgroRentMenuHud);