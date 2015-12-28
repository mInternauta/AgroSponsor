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
AgroPlayerProfHud = {};

source(AgroSponsor.ModInstallDir .. 'huds/hudProgressBar.lua')

-- Initialize the Menu
function AgroPlayerProfHud:init() 
	-- Menu List 
	self.MenuList = {}
	
	-- Overlays
	self.backOverlay = createImageOverlay(Utils.getFilename('img/menu.png', AgroSponsor.ModInstallDir));

	-- Progress Bar - Experience
	self.pbExperience = createProgressBar(0.41,0.58);
	self.pbExperience:setMaxValue(AgroPlayerProfile:getExperiencePerLevel());
	self.pbExperience:setValue(AgroPlayerProfile:getMissingExp());
	
	-- set default visibility
	self.visible = false;
	self.myTitle = as.utils.getText('AGROSPONSOR_MMPROFILE');
end 

function AgroPlayerProfHud:show()
	self.visible = true;
end 

function AgroPlayerProfHud:hide()
	self.visible = false;
	
	-- DISABLE the mouse 
	asMouseHud:setEnabled(false);
end 

function AgroPlayerProfHud:update(dt) 	 
	self.pbExperience:setMaxValue(AgroPlayerProfile:getExperiencePerLevel());
	self.pbExperience:setValue(AgroPlayerProfile:getMissingExp());
end 

function AgroPlayerProfHud:draw()
	if self.visible then 
		-- Render the overlay
		renderOverlay(self.backOverlay, 0.4, 0.30, 0.20, 0.42);	
		
		-- Render the Player Level		
		self:drawLevel();
		
		-- Render the Player Experience
		self:drawExp();
		
		-- Render the Sponsor
		self:drawSponsor();
		
		-- Render the title
		renderText(0.41, 0.69, 0.022, self.myTitle);
		
		-- QUIT
		renderText(0.41, 0.31, 0.018, as.utils.getText('AGROSPONSOR_EXITKEY'));
		
		-- Enable the mouse 
		asMouseHud:setEnabled(true);
	end
end 

function AgroPlayerProfHud:drawLevel()			
	setTextColor(0,0,0, 1);
	
	local text =  as.utils.getText('AGROSPONSOR_LEVEL') .. ': ';
	renderText(0.41, 0.64, 0.019, text);
	
	setTextBold(true);		
	
	renderText(0.41 + getTextWidth(0.019, text) + 0.0055, 0.64, 0.019, tostring(AgroPlayerProfile:getLevel()));

	setTextColor(1,1,1, 1);
	setTextBold(false);
end 

function AgroPlayerProfHud:drawExp()
	setTextColor(0,0,0, 1);
	local text =  as.utils.getText('AGROSPONSOR_EXP') .. ': ';
	renderText(0.41, 0.62, 0.019, text);
	
	setTextBold(true);		
	
	renderText(0.41 + getTextWidth(0.019, text) + 0.0055, 0.62, 0.019, tostring(AgroPlayerProfile:getExperience()));

	setTextColor(1,1,1, 1);
	setTextBold(false);
	
	self.pbExperience:draw();
end 

function AgroPlayerProfHud:drawSponsor()
	if AgroSpManager.Sponsor ~= nil then 
		setTextColor(0,0,0, 1);
		local text =  as.utils.getText('AGROSPONSOR_SPONSOR') .. ': ';
		renderText(0.41, 0.54, 0.019, text);
		
		-- Sponsor Name
		setTextBold(true);	
		renderText(0.41, 0.50, 0.019, AgroSpManager.Sponsor['Title']);
		
		-- Daily Ship		
		local text =  as.utils.getText('AGROSPONSOR_DAILYSHIP') .. ': ';
		renderText(0.41, 0.48, 0.019, text);
		renderText(0.41 + getTextWidth(0.019, text) + 0.0055, 0.48, 0.019, g_i18n:formatMoney(AgroSpManager.Sponsor['Ship']));
		
		local text =  as.utils.getText('AGROSPONSOR_MAXREWARD') .. ': ';
		renderText(0.41, 0.46, 0.019, text);
		renderText(0.41 + getTextWidth(0.019, text) + 0.0055, 0.46, 0.019, g_i18n:formatMoney(AgroSpManager.Sponsor['Reward']));
		
		setTextColor(1,1,1, 1);
		setTextBold(false);
	end 
end 

function AgroPlayerProfHud:deleteMap()	
end;

function AgroPlayerProfHud:loadMap(name)
end;

function AgroPlayerProfHud:keyEvent(unicode, sym, modifier, isDown)
	if sym == Input.KEY_q and isDown == true and self.visible then
		self:hide();
	end;
end;

function AgroPlayerProfHud:mouseEvent(posX, posY, isDown, isUp, button)
end;

addModEventListener(AgroPlayerProfHud);