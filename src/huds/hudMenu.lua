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
AgroMenuHud = {};
AgroMenuHud.__index  = AgroMenuHud;
local AgroMenuHud_mt = Class(AgroMenuHud);


-- Load the Dependencies
source(AgroSponsor.ModInstallDir .. 'huds/hudMouse.lua')

-- Max Childrens in the menu
AgroMenuHud.MaxItems = 6;
AgroMenuHud.imgRatioH = 0.0465;
AgroMenuHud.imgRatioW = 0.17;
AgroMenuHud.startPosX = 0.4145;
AgroMenuHud.startPosY = 0.54;

function createMenuInstance(title)
	local menu = {}
	setmetatable(menu, AgroMenuHud);
		
	menu:init();
	menu:setTitle(title);
	
	return menu;
end 

-- Initialize the Menu
function AgroMenuHud:init() 
	-- Menu List 
	self.MenuList = {}
	
	-- Overlays
	self.backOverlay = createImageOverlay(Utils.getFilename('img/menu.png', AgroSponsor.ModInstallDir));
	self.mOverlay = createImageOverlay(Utils.getFilename('img/menuBarHover.png', AgroSponsor.ModInstallDir));
	
	--
	self.mX = 0;
	self.mY = 0;
	self.hvMenuID = nil;
	self.mVisible = false;
	
	-- set default visibility
	self.visible = false;
	self.myTitle = "Menu";
end 

function AgroMenuHud:setTitle(title)
	self.myTitle = title;
end 

function AgroMenuHud:show()
	self.visible = true;
end 

function AgroMenuHud:hide()
	self.visible = false;
	
	-- DISABLE the mouse 
	asMouseHud:setEnabled(false);
end 

-- Add a item to the menu 
function AgroMenuHud:addItem(id, text, func)
	self.MenuList[id] = {};
	self.MenuList[id].Text = text;
	self.MenuList[id].Func = func;
	
	self:buildMenu();
end 

-- Clear the Menu
function AgroMenuHud:clear()
	self.MenuList = {};
end 

-- Build the menu list 
function AgroMenuHud:buildMenu()
	self.menu = {};
	
	local menuCount = 1;
	for id, data in pairs(self.MenuList) do 
		local menuOverlay = createImageOverlay(Utils.getFilename('img/menuBar.png', AgroSponsor.ModInstallDir));
		local menuOverlayH = AgroMenuHud.imgRatioH;
		local menuOverlayW = AgroMenuHud.imgRatioW;
		local menuOverlayX = AgroMenuHud.startPosX;
		local menuOverlayY = AgroMenuHud.startPosY + (0.062 * (menuCount - 1));
		
		local menuData = {};
		menuData['Overlay'] = menuOverlay;
		menuData['H'] = menuOverlayH;
		menuData['W'] = menuOverlayW;
		menuData['X'] = menuOverlayX;
		menuData['Y'] = menuOverlayY;
		menuData['Text'] = data.Text;
		menuData['ID'] = id;
			
		self.menu[id] = menuData;
		
		menuCount = menuCount + 1;
		
		if menuCount >= AgroMenuHud.MaxItems then 
			break;
		end
	end 
end 

function AgroMenuHud:update(dt) 
	-- Check if the mouse is inside of any menu item overlay 
	for id, data in pairs(self.menu) do 
		local isMouseInside = asMouseHud:isInsideOf(data['X'], data['Y'], data['W'], data['H']);
		if isMouseInside then 
			self.mVisible = true;
			self.mX = data['X'];
			self.mY = data['Y'];	
			self.hvMenuID = id;
			break;			
		else
			self.hvMenuID = nil;		
			self.mVisible = false;			
		end 
	end 
end 

function AgroMenuHud:draw()
	if self.visible then 
		-- Render the overlay
		renderOverlay(self.backOverlay, 0.4, 0.30, 0.20, 0.42);	
		
		for name, data in pairs(self.menu) do 
			renderOverlay(data['Overlay'], data['X'], data['Y'], data['W'], data['H']);
			
			-- Render Text 
			local textX = data['X'] + 0.01;
			local textY = data['Y'] + 0.0155;
			
			setTextColor(0,0,0, 1);
			setTextBold(true);
			
			renderText(textX, textY, 0.020, data['Text']);
			
			setTextBold(false);
			setTextColor(1,1,1, 1);
		end 
		
		-- Render the title
		renderText(0.41, 0.69, 0.022, self.myTitle);
		
		-- QUIT
		renderText(0.41, 0.31, 0.018, as.utils.getText('AGROSPONSOR_EXITKEY'));
		
		-- Render the Mouse Overlay 
		if self.mVisible then 
			renderOverlay(self.mOverlay, self.mX, self.mY, AgroMenuHud.imgRatioW, AgroMenuHud.imgRatioH);
		end 
		
		-- Enable the mouse 
		asMouseHud:setEnabled(true);
	end
end 

function AgroMenuHud:deleteMap()	
end;

function AgroMenuHud:loadMap(name)
end;

function AgroMenuHud:keyEvent(unicode, sym, modifier, isDown)
	if sym == Input.KEY_q and isDown == true and self.visible then
		self:hide();
	end;
end;

function AgroMenuHud:mouseEvent(posX, posY, isDown, isUp, button)
	if isDown and self.hvMenuID ~= nil and self.visible then
		self.selectedMenu = self.MenuList[self.hvMenuID];
						
		self.selectedMenu.Func();
	end 
end;