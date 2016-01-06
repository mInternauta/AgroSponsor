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
if AgroPageTab == nil then 
AgroPageTab = {};
AgroPageTab.__index  = AgroPageTab;
local AgroPageTab_mt = Class(AgroPageTab);

source(AgroSponsor.ModInstallDir .. 'huds/hudButton.lua')

function createPageTab(x, y, w, h)
	local tb  = {}
	setmetatable(tb, AgroPageTab);
		
	tb:init();
	tb:setPosition(x, y);
	tb:setSize(w, h);
	
	return tb;
end 


-- Functions
function AgroPageTab:init()
	-- Page List 
	self.List = {}
		
	--
	self.posX = 0;
	self.posY = 0;
	self.selectedId = nil;
	self.myW = 0;
	self.myH = 0;
	
	-- set default visibility
	self.visible = false;
	self.isHoverButton = false;
end 

function AgroPageTab:_setButtonsVisible(visible)
	for id, item in pairs(self.List) do 
		if visible then 
			item['Button']:show();
		else 
			item['Button']:hide();
		end 
	end 
end 

function AgroPageTab:show()
	self.visible = true;
	self:_setButtonsVisible(true);
end 

function AgroPageTab:hide()
	self.visible = false;
	self:_setButtonsVisible(false);
end 

function AgroPageTab:setPosition(x,y)
	self.posX = x;
	self.posY = y;
end 

function AgroPageTab:setSize(w,h)
	self.myW = w;
	self.myH = h;
end 

function AgroPageTab:update()
end 

function AgroPageTab:draw()
	-- Buttons already render it self
	
	-- Render the current page		
	if self.selectedId ~= nil then 
		local renFunc = self.List[self.selectedId]['Render'];
		renFunc();
	end 
end 

-- Add a New Item to the Box
function AgroPageTab:add(id, title, renderFunc)
	local currentLen = as.tables.len(self.List)

	self.List[id] = {};
	self.List[id]['Render'] = renderFunc;
	self.List[id]['Button'] = createButton(self.posX + (currentLen * 0.103), self.posY + self.myH);
	self.List[id]['Button']:setTitle(title);
	
	local clickHandler = function (btn)	 
			--as.utils.print_r(btn)
			if btn:getMyTag() ~= nil then 
				local data = btn:getMyTag();
				data['PageTab']:setSelected(data['ID']);
			end 
		end 
	
	self.List[id]['Button']:bindOnClick('Click', clickHandler);
	
	local btnTag = {}
	btnTag['PageTab'] = self;
	btnTag['ID'] = id;
	
	self.List[id]['Button']:setMyTag(btnTag);
end 

--
function AgroPageTab:clear()
	self.List = {}
	self.selectedId = nil;
end 

function AgroPageTab:getSelected()
	return self.selectedId;
end 

function AgroPageTab:setSelected(id)
	self.selectedId = id;
end 
end