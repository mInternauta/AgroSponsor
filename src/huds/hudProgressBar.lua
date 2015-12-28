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
if AgroProgressBar == nil then

AgroProgressBar = {}
AgroProgressBar.__index = AgroProgressBar;

local AgroProgressBar_mt = Class(AgroProgressBar);

function createProgressBar(x, y)
	local pb = {}
	setmetatable(pb, AgroProgressBar);
		
	pb:init();
	pb:setPosition(x, y);
	
	return pb;
end 


-- Progress Bar
function AgroProgressBar:init() 
	self.pbBack = createImageOverlay(Utils.getFilename('img/progressBarBack.png', AgroSponsor.ModInstallDir));
	self.pbFull = createImageOverlay(Utils.getFilename('img/progressBarFull.png', AgroSponsor.ModInstallDir));
	self.cPbW = 0.18;
end 

function AgroProgressBar:setPosition(x,y)
	self.pbX = x;
	self.pbY = y;
end 

function AgroProgressBar:setMaxValue(maxVal)
	self.maxValue = maxVal;
end 

function AgroProgressBar:setValue(val)
	self.value = val;
	
	if self.maxValue == nil then 
		self.maxValue = val;
	end
	
	local perc = (val / self.maxValue);
	local final = 0.18 * perc;
	
	self.cPbW = final;
end 

function AgroProgressBar:draw()
	-- Render the Back Overlay
	renderOverlay(self.pbBack, self.pbX, self.pbY, 0.18, 0.01825);
	
	-- Render the Bar Overlay
	renderOverlay(self.pbFull, self.pbX, self.pbY, self.cPbW, 0.01825);
end 

end