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
source(AgroSponsor.ModInstallDir .. 'huds/hudPageTab.lua')
source(AgroSponsor.ModInstallDir .. 'huds/hudButton.lua')
source(AgroSponsor.ModInstallDir .. 'huds/hudGrid.lua')

-- Initialize the Menu
function AgroRentMenuHud:init() 	
	-- Overlays
	self.backOverlay = createImageOverlay(Utils.getFilename('img/rentMenu.png', AgroSponsor.ModInstallDir));
	self.backItemOverlay = createImageOverlay(Utils.getFilename('img/rentItemBack.png', AgroSponsor.ModInstallDir));
	self.spoOverlay = createImageOverlay(Utils.getFilename('img/sponsored.png', AgroSponsor.ModInstallDir));

	-- Categories ComboBox
	self.cbCategories = createComboBox(0.21,0.665);
	
	-- Items ComboBox
	self.cbItems = createComboBox(0.40,0.665);
	
	-- Page Tab
	self.tbMenu = createPageTab(0.21, 0.20, 0.52, 0.53);
	
	-- Add the Tabs 
	self.tbMenu:add('tbRent',  as.utils.getText('AGROSPONSOR_RENT'), AgroRentMenuHud._renderRentMenu);
	self.tbMenu:add('tbHistory',  as.utils.getText('AGROSPONSOR_RENTHISTORY'), AgroRentMenuHud._renderRentHist);
	
	-- Rent Button
	self.btnRent = createButton(0.62, 0.285);
	self.btnRent:setTitle(as.utils.getText('AGROSPONSOR_RENT'));
	
	local rentHandler = function (btn)
		if btn:getMyTag() ~= nil then 
			local data = btn:getMyTag();
			AgroRentMenuHud:onRentItem(data);
		end 
	end 
	
	self.btnRent:bindOnClick('Click', rentHandler);
	
	-- History Grid 
	self.grdRents = createGrid(0.23, 0.265);	
	self.grdRentsButtons = {};

	-- Build the Columns 
	local rdText = function(dataId, dataSourceItem, posX, posY)
		return AgroGrid:renderText(dataSourceItem, posX, posY, 0.020);		
	end 
	
	local grdRentRdButton = function(dataId, dataSourceItem, posX, posY)
		local button = AgroRentMenuHud.grdRentsButtons[dataSourceItem];
		button:setPosition(posX, posY - 0.006);
		button:render();
	end 
		
	self.grdRents:addColumn("Expired", as.utils.getText('AGROSPONSOR_STATE'), rdText);
	self.grdRents:addColumn("Price", as.utils.getText('AGROSPONSOR_PRICE'), rdText);
	self.grdRents:addColumn("Name", as.utils.getText('AGROSPONSOR_NAME'), rdText);
	self.grdRents:addColumn("ID", "-", grdRentRdButton);
	
	self.grdRents:setPaddingY(0.012);
	
	-- Build Data
	self:updateRentGrid();
	
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
	
	-- set the default page 
	self.tbMenu:setSelected('tbRent');
	
	-- set default visibility
	self.visible = false;
	self.myTitle = as.utils.getText('AGROSPONSOR_RENTTITLE');
end 

function AgroRentMenuHud:updateRentGrid()
	local data = {}
	for rentId, rent in pairs(AgroRentManager.Rents) do 
		data[rentId] = {}
		data[rentId]["Name"] = rent["Name"]
		data[rentId]["Price"] = as.utils.toMoneyString(rent["Price"])
		data[rentId]["ID"] = rentId;
		
		-- Add the Buttom
		if self.grdRentsButtons[rentId] == nil then 
			self.grdRentsButtons[rentId] = createButton(0.1, 0.1);
			self.grdRentsButtons[rentId]:setAutoDraw(false);
			self.grdRentsButtons[rentId]:setTitle(as.utils.getText('AGROSPONSOR_GIVEBACK'));
			self.grdRentsButtons[rentId]:setSize(0.06, 0.03, 0.018);			
			
			local onClickGiveBack = function(btn)
				if btn:getMyTag() ~= nil then 
					AgroRentMenuHud:onUnRentItem(btn:getMyTag());
				end 
			end 
			
			self.grdRentsButtons[rentId]:bindOnClick("unRentClick", onClickGiveBack);
		end 
				
		if rent["Expired"] then 
			data[rentId]["Expired"] = as.utils.getText('AGROSPONSOR_EXPIRED');
			self.grdRentsButtons[rentId]:hide();
		else 
			data[rentId]["Expired"] = as.utils.getText('AGROSPONSOR_ACTIVATED');
			self.grdRentsButtons[rentId]:show();
			self.grdRentsButtons[rentId]:setMyTag(rentId);
		end 
	end 
	self.grdRents:setDataSource(data);
end 

function AgroRentMenuHud:onUnRentItem(rentId)
	AgroRentManager:remove(rentId);
end 

function AgroRentMenuHud:onRentItem(item)
	AgroRentManager:rent(item);
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
	
	if id ~= nil then 
		self.selectedItem = AgroRentManager:create(id);
		
		self.curImgOverlay = createImageOverlay(self.selectedItem['Store']['imageActive']);
		self.btnRent:setMyTag(self.selectedItem);	
	end 
end 

function AgroRentMenuHud:show()
	self.visible = true;
	self.cbCategories:show();
	self.cbItems:show();
	self.tbMenu:show();
	
	AgroRentMenuHud:onItemChange();
end 

function AgroRentMenuHud:hide()
	self.visible = false;
	
	self.cbCategories:hide();
	self.cbItems:hide();
	self.tbMenu:hide();
	self.btnRent:hide();
	self.grdRents:hide();
	
	-- DISABLE the mouse 
	asMouseHud:setEnabled(false);
end 

function AgroRentMenuHud:update(dt) 	 
	self.cbCategories:update();
	self.cbItems:update();
	self:updateRentGrid();
end 

function AgroRentMenuHud:draw()
	if self.visible then 
		-- Render the overlay
		renderOverlay(self.backOverlay, 0.2, 0.2, 0.62, 0.63);			
				
		-- Render the title
		renderText(0.205, 0.795, 0.022, self.myTitle);	
		
		-- QUIT
		renderText(0.205, 0.21, 0.018, as.utils.getText('AGROSPONSOR_EXITKEY'));
		
		-- Exp Tip
		renderText(0.631, 0.22, 0.018, as.utils.getText('AGROSPONSOR_RENTEXPTIP'));
		
		-- Price Tip
		renderText(0.461, 0.22, 0.018, as.utils.getText('AGROSPONSOR_RENTPRICETIP'));
		
		self.btnRent:hide();
		self.grdRents:hide();
		
		-- Render the Page Tab
		self.tbMenu:draw();
		
		-- Enable the mouse 
		asMouseHud:setEnabled(true);
	else 
		self.btnRent:hide();
		self.grdRents:hide();
	end
end 

function AgroRentMenuHud:_renderRentHist()
	AgroRentMenuHud:renderRentHist();
end 

function AgroRentMenuHud:renderRentHist()
	-- Render Rent History
	setTextColor(0,0,0, 1);
	setTextBold(true);
	
	renderText(0.21, 0.708, 0.022, as.utils.getText('AGROSPONSOR_RENTHISTORY'));
	
	setTextColor(1,1,1, 1);
	setTextBold(false);
	
	-- Enable the Grid
	self.grdRents:show();
end 

function AgroRentMenuHud:_renderRentMenu()
	AgroRentMenuHud:renderRentMenu();
end 

function AgroRentMenuHud:renderRentMenu()
	-- Render Rent Menu
	setTextColor(0,0,0, 1);
	setTextBold(true);
	
	renderText(0.21, 0.708, 0.018, as.utils.getText('AGROSPONSOR_RENTBRAND'));
	renderText(0.40, 0.708, 0.018, as.utils.getText('AGROSPONSOR_RENTEQ'));
	
	setTextColor(1,1,1, 1);
	setTextBold(false);
	
	-- ComboBox
	self.cbCategories:draw();
	self.cbItems:draw();
	
	-- Button
	if g_currentMission.missionStats.money > self.selectedItem['Price'] then 
		self.btnRent:show();
	end 
	
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
							
		setTextColor(1,1,1, 1);
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