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
if AgroComboBox == nil then 
AgroComboBox = {};
AgroComboBox.__index  = AgroComboBox;
local AgroComboBox_mt = Class(AgroComboBox);

-- Load the Dependencies
source(AgroSponsor.ModInstallDir .. 'huds/hudMouse.lua')

AgroComboBox.ButtonW = 0.021;
AgroComboBox.ButtonH = 0.019;
AgroComboBox.ButtonOffsetX = 0.158;

function createComboBox(x, y)
	local cb = {}
	setmetatable(cb, AgroComboBox);
		
	cb:init();
	cb:setPosition(x, y);
	
	return cb;
end 

-- Functions
function AgroComboBox:init()
	-- Combo List 
	self.List = {}
	
	-- Overlays
	self.backOverlay = createImageOverlay(Utils.getFilename('img/comboBoxBack.png', AgroSponsor.ModInstallDir));
	self.mOverlay = createImageOverlay(Utils.getFilename('img/cbSelected.png', AgroSponsor.ModInstallDir));
	self.upOverlay = createImageOverlay(Utils.getFilename('img/cbSelectUp.png', AgroSponsor.ModInstallDir));
	self.downOverlay = createImageOverlay(Utils.getFilename('img/cbSelectDown.png', AgroSponsor.ModInstallDir));
	
	--
	self.posX = 0;
	self.posY = 0;
	self.selectedIndex = 0;
	self.btDownY = 0;
	self.btUpY = 0;
	self.btX = 0;
	self.itemChangeEvents = {}
	
	-- set default visibility
	self.visible = false;
	self.isHoverButton = false;
end 

function AgroComboBox:show()
	self.visible = true;
end 

function AgroComboBox:hide()
	self.visible = false;
end 

function AgroComboBox:setPosition(x,y)
	self.posX = x;
	self.posY = y;
	self:buildPositions();
end 

function AgroComboBox:buildPositions()
	self.btX = self.posX + AgroComboBox.ButtonOffsetX;
	self.btDownY = self.posY + 0.0014; 
	self.btUpY = self.posY + 0.0014 + AgroComboBox.ButtonH; 
end 

function AgroComboBox:update()
	local isMouseInsideDown = asMouseHud:isInsideOf(self.btX, self.btDownY, AgroComboBox.ButtonW, AgroComboBox.ButtonH);
	if isMouseInsideDown then
		self.isHoverButton = true;
		self.hvPosX = self.btX;
		self.hvPosY = self.btDownY;
		self.hvButton = 0;
	else 
		local isMouseInsideUp = asMouseHud:isInsideOf(self.btX, self.btUpY, AgroComboBox.ButtonW, AgroComboBox.ButtonH);
		if isMouseInsideUp then
			self.isHoverButton = true;
			self.hvPosX = self.btX;
			self.hvPosY = self.btUpY;
			self.hvButton = 1;
		else 
			self.isHoverButton = false;
		end
	end
end 


function AgroComboBox:nextItem()
	local maxIndex = as.tables.len(self.List);
	local nextIndex = self.selectedIndex + 1;
	
	if nextIndex < maxIndex then 
		self.selectedIndex = nextIndex;
	end 
end 

function AgroComboBox:prevItem()
	local prevIndex = self.selectedIndex - 1;
	if prevIndex >= 0 then 
		self.selectedIndex = prevIndex;
	end 
end 

function AgroComboBox:draw()
	if self.visible then 
		-- Render the Back
		renderOverlay(self.backOverlay, self.posX, self.posY, 0.18, 0.041);
		
		-- Render the buttons
		renderOverlay(self.upOverlay, self.btX, self.btUpY, AgroComboBox.ButtonW, AgroComboBox.ButtonH);
		renderOverlay(self.downOverlay, self.btX, self.btDownY, AgroComboBox.ButtonW, AgroComboBox.ButtonH);
		
		-- Render the hover button 
		if self.isHoverButton then 
			renderOverlay(self.mOverlay, self.hvPosX, self.hvPosY, AgroComboBox.ButtonW, AgroComboBox.ButtonH);	
		end 
		
		-- Render the Text
		setTextColor(0,0,0, 1);
		setTextBold(true);
		local slKey = self:getSelected();
		local text = self.List[slKey];
		
		if text ~= nil then
			renderText(self.posX + 0.008, self.posY + 0.01, 0.022, text);
		end 
		
		setTextColor(1,1,1, 1);
		setTextBold(false);
	end 
end 

function AgroComboBox:onMouseDown()			
	if self.hvButton == 1 and self.isHoverButton then 
		self:prevItem();
		
		self:invokeOnChange();
	elseif self.hvButton == 0 and self.isHoverButton then 
		self:nextItem();
		
		self:invokeOnChange();
	end 
end 

-- Events
function AgroComboBox:bindOnChange(id, func)
	self.itemChangeEvents[id] = func;
end 

function AgroComboBox:invokeOnChange()
	for k,v in pairs(self.itemChangeEvents) do 
		v();
	end 		
end 

-- Add a New Item to the Box
function AgroComboBox:add(id, text)
	self.List[id] = text;
end 

--
function AgroComboBox:clear()
	self.List = {}
	self.selectedIndex = 0;
end 

function AgroComboBox:getSelected()
	local items = as.tables.len(self.List);
	
	if items > 0 then 
		return as.tables.getKeyInIndex(self.selectedIndex, self.List);
	else 
		return nil;
	end 
end 
end