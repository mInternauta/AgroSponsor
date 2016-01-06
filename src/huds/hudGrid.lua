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
AgroGrid.__index  = AgroButton;
local AgroGrid_mt = Class(AgroGrid);

AgroGrid.LineH = 0.04;

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
	self.maxItemPerView = 8;
	self.currentBeginIndex = 0;
	self.currentEndIndex = 8;
	
	-- Overlays
	self.backOverlay = createImageOverlay(Utils.getFilename('img/gridOverlay.png', AgroSponsor.ModInstallDir));	
	self.upOverlay = createImageOverlay(Utils.getFilename('img/cbSelectUp.png', AgroSponsor.ModInstallDir));
	self.downOverlay = createImageOverlay(Utils.getFilename('img/cbSelectDown.png', AgroSponsor.ModInstallDir));
	--
	self.posX = 0;
	self.posY = 0;
	
	-- set default visibility
	self.visible = false;
end 

-- Column Functions
function AgroGrid:addColumn(dataId, title)
	self.Columns[dataId] = {}
	self.Columns[dataId]["ID"] = dataId;
	self.Columns[dataId]["Title"] = title;
end 

-- DataSource Functions 

function AgroGrid:show()
	self.visible = true;
end 

function AgroGrid:hide()
	self.visible = false;
end 

function AgroGrid:setPosition(x,y)
	self.posX = x;
	self.posY = y;
end 

function AgroGrid:update(dt)
	local isMouseInside = asMouseHud:isInsideOf(self.posX, self.posY, AgroButton.ButtonW, AgroButton.ButtonH);
	if isMouseInside then
		self.isHoverButton = true;
	else 
		self.isHoverButton = false;
	end
end 

function AgroGrid:draw()
	if self.visible then 
		-- Render the Back
		renderOverlay(self.backOverlay, self.posX, self.posY, 0.4, 0.2);
		
	end 
end 

function AgroGrid:deleteMap()	
end;

function AgroGrid:loadMap(name)
end;

function AgroGrid:mouseEvent(posX, posY, isDown, isUp, button)
end

function AgroGrid:keyEvent(unicode, sym, modifier, isDown)
end 

end 