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
if AgroGrid == nil then 
AgroGrid = {};
AgroGrid.__index  = AgroGrid;
local AgroGrid_mt = Class(AgroGrid);

AgroGrid.LineH = 0.04;
AgroGrid.ButtonW = 0.021;
AgroGrid.ButtonH = 0.019;

function createGrid(x, y)
	local grid = {}
	setmetatable(grid, AgroGrid);
		
	grid:init();
	grid:setPosition(x, y);
	
	addModEventListener(grid);
	
	return grid;
end 

-- Functions
function AgroGrid:init()
	-- Grid Columns
	self.Columns = {}
	
	-- Grid Data
	self.DataSource = {}
	
	-- Item Index
	self.maxItemPerView = 10;
	self.currentBeginIndex = 0;
	self.currentEndIndex = 10;
	
	-- Overlays
	self.backOverlay = createImageOverlay(Utils.getFilename('img/gridOverlay.png', AgroSponsor.ModInstallDir));	
	self.upOverlay = createImageOverlay(Utils.getFilename('img/cbSelectUp.png', AgroSponsor.ModInstallDir));
	self.downOverlay = createImageOverlay(Utils.getFilename('img/cbSelectDown.png', AgroSponsor.ModInstallDir));
	self.mOverlay = createImageOverlay(Utils.getFilename('img/cbSelected.png', AgroSponsor.ModInstallDir));
	--
	self.posX = 0;
	self.posY = 0;
	
	self.upPosX = self.posX + 0.5;
	self.upPosY = self.posY + 0.2;	
	self.downPosX = self.posX + 0.5;
	self.downPosY = self.posY + 0.04;
	
	self.eSpY = 0;
	
	self.hvX = 0;
	self.hvY = 0;
	self.isHover = 0;
	
	-- set default visibility
	self.visible = false;
end 

-- Column Functions
-- renderFunc = function(dataId, dataSourceItem, posX, posY)
-- 	return weight, height 
-- end 
function AgroGrid:addColumn(dataId, title, renderFunc)
	self.Columns[dataId] = {}
	self.Columns[dataId]["ID"] = dataId;
	self.Columns[dataId]["Title"] = title;
	self.Columns[dataId]["Render"] = renderFunc;
end 

-- DataSource Functions 
function AgroGrid:setDataSource(dataSource)
	self.DataSource = dataSource;
end 

function AgroGrid:GoUp()
	if self.currentBeginIndex > 0 then 
		self.currentBeginIndex = self.currentBeginIndex - 1;
		self.currentEndIndex = self.currentEndIndex - 1;
		
		if self.currentEndIndex < self.maxItemPerView then 
			self.currentEndIndex = self.maxItemPerView;
		end 
	end 
end

function AgroGrid:GoDown()
	local count = as.tables.len(self.DataSource);
	
	if self.currentEndIndex < count then 
		self.currentBeginIndex = self.currentBeginIndex + 1;
		self.currentEndIndex = self.currentEndIndex + 1;
	end 
end 

function AgroGrid:setPaddingY(y)
	self.eSpY = y;
end 

function AgroGrid:show()
	self.visible = true;
end 

function AgroGrid:hide()
	self.visible = false;
end 

function AgroGrid:setPosition(x,y)
	self.posX = x;
	self.posY = y;
	
	self.upPosX = self.posX + 0.5403;
	self.upPosY = self.posY + 0.355;	
	self.downPosX = self.posX + 0.5403;
	self.downPosY = self.posY + 0.01;
end 

function AgroGrid:update(dt)
	local isMouseInside = asMouseHud:isInsideOf(self.upPosX, self.upPosY, AgroGrid.ButtonW, AgroGrid.ButtonH);
	if isMouseInside then
		self.isHover = 1;
		self.hvX = self.upPosX;
		self.hvY = self.upPosY;
	else 
		isMouseInside = asMouseHud:isInsideOf(self.downPosX, self.downPosY, AgroGrid.ButtonW, AgroGrid.ButtonH);
		if isMouseInside then 
			self.isHover = 2;
			self.hvX = self.downPosX;
			self.hvY = self.downPosY;
		else 
			self.isHover = 0;
		end 
	end
end 

function AgroGrid:renderText(text, posX, posY, size)
	setTextColor(0,0,0, 1);
	renderText(posX, posY, size, text);							
	setTextColor(1,1,1, 1);
	
	local tW = getTextWidth(size, text);
	local tH = getTextHeight(size, text);
	
	return tW, tH
end 

function AgroGrid:draw()
	if self.visible then 
		-- Render the Back
		renderOverlay(self.backOverlay, self.posX, self.posY, 0.5613, 0.4289);
		
		-- Render the Columns 
		local cIndex = 0;
		local cWidth, cHeight;
		cHeight = 0
		cWidth = 0
		
		for dataId, item in pairs(self.Columns) do 
			local lineX = self.posX + 0.01 + (cIndex * 0.128);
		
			-- Render all current column lines 
			if self.DataSource ~= nil then 
				for dataSrcItemID, cData in pairs(self.DataSource) do					
					local index = as.tables.getKeyIndex(dataSrcItemID, self.DataSource);
					local tIndex = index - self.currentBeginIndex;
					
					local lineY = (self.posY + 0.335) - (tIndex * (0.02 + self.eSpY));
				
					if cData ~= nil and index >= self.currentBeginIndex and index <= self.currentEndIndex then 
						local cLine = cData[dataId];
						local cRender = item['Render'];
												
						if cLine ~= nil then 
							cWidth, cHeight = cRender(dataId, cLine, lineX, lineY);
						end 
					end 
				end 
			end 
		
			-- Render the Column Title 
			setTextColor(1,1,1, 1);
			setTextBold(true);
			
			renderText(lineX, self.posY + 0.39, 0.022, item['Title']);							
			
			setTextBold(false);
			setTextColor(1,1,1, 1);
			
			cIndex = cIndex + 1;
		end 
		
		-- Render the Buttons 
		renderOverlay(self.downOverlay, self.downPosX, self.downPosY, AgroGrid.ButtonW, AgroGrid.ButtonH);
		renderOverlay(self.upOverlay, self.upPosX, self.upPosY, AgroGrid.ButtonW, AgroGrid.ButtonH);
		
		-- Render Button Hover 
		if self.isHover > 0 then 
			renderOverlay(self.mOverlay, self.hvX, self.hvY, AgroGrid.ButtonW, AgroGrid.ButtonH);
		end 
	end 
end 

function AgroGrid:deleteMap()	
end;

function AgroGrid:loadMap(name)
end;

function AgroGrid:mouseEvent(posX, posY, isDown, isUp, button)
	if self.isHover == 1 and isDown then
		self:GoUp();
	elseif self.isHover == 2 and isDown then 
		self:GoDown();
	end 
end

function AgroGrid:keyEvent(unicode, sym, modifier, isDown)
end 

end 