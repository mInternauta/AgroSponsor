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
if AgroButton == nil then 
AgroButton = {};
AgroButton.__index  = AgroButton;
local AgroButton_mt = Class(AgroButton);

-- Load the Dependencies
source(AgroSponsor.ModInstallDir .. 'huds/hudMouse.lua')

AgroButton.ButtonW = 0.1;
AgroButton.ButtonH = 0.04;

function createButton(x, y)
	local btn = {}
	setmetatable(btn, AgroButton);
		
	btn:init();
	btn:setPosition(x, y);
	
	addModEventListener(btn);
	
	return btn;
end 


-- Functions
function AgroButton:init()
	-- Button Title
	self.Title = ""
	
	-- Overlays
	self.backOverlay = createImageOverlay(Utils.getFilename('img/btnBack.png', AgroSponsor.ModInstallDir));
	self.mOverlay = createImageOverlay(Utils.getFilename('img/btnBackOver.png', AgroSponsor.ModInstallDir));
	
	--
	self.posX = 0;
	self.posY = 0;
	self.clickEvents = {}
	
	-- set default visibility
	self.visible = false;
	self.isHoverButton = false;
end 

function AgroButton:setTitle(title)
	self.Title = title;
end 

function AgroButton:show()
	self.visible = true;
end 

function AgroButton:hide()
	self.visible = false;
end 

function AgroButton:setPosition(x,y)
	self.posX = x;
	self.posY = y;
end 

function AgroButton:setMyTag(tag)
	self.myTag = tag;
end 

function AgroButton:getMyTag()
	return self.myTag;
end 

function AgroButton:update(dt)
	local isMouseInside = asMouseHud:isInsideOf(self.posX, self.posY, AgroButton.ButtonW, AgroButton.ButtonH);
	if isMouseInside then
		self.isHoverButton = true;
	else 
		self.isHoverButton = false;
	end
end 

function AgroButton:draw()
	if self.visible then 
		-- Render the Back
		renderOverlay(self.backOverlay, self.posX, self.posY, AgroButton.ButtonW, AgroButton.ButtonH);
		
		-- Render the hover button 
		if self.isHoverButton then 
			renderOverlay(self.mOverlay, self.posX, self.posY, AgroButton.ButtonW, AgroButton.ButtonH);	
		end 
		
		-- Render the Text
		setTextBold(true);

		renderText(self.posX + 0.008, self.posY + 0.01, 0.022, self.Title);

		setTextBold(false);
	end 
end 

function AgroButton:deleteMap()	
end;

function AgroButton:loadMap(name)
end;

function AgroButton:mouseEvent(posX, posY, isDown, isUp, button)
	if self.isHoverButton and isDown then 
		self:invokeOnClick();
	end 
end

function AgroButton:keyEvent(unicode, sym, modifier, isDown)
end 

-- Events
function AgroButton:bindOnClick(id, func)
	self.clickEvents[id] = func;
end 

function AgroButton:invokeOnClick()
	local btn = self;
	for k,v in pairs(self.clickEvents) do 
		v(btn);
	end 		
end 
end 