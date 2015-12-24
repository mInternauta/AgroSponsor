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
hudSponsors = {}

-- Max sponsors can be show in the hud (CONSTANT)
hudSponsors.maxSponsors = 6; 

-- Max sponsors can be show in a line on the hud (CONSTANT)
hudSponsors.perLineSponsors = 3;

-- Sponsor Start Position 
hudSponsors.startPosX = 0.274;
hudSponsors.startPosY = 0.632;

hudSponsors.spImgRatio = 0.18;

local hudSponsors_mt = Class(hudSponsors);

-- Load the Depedencies
source(AgroSponsor.ModInstallDir .. 'huds/hudMouse.lua')
source(AgroSponsor.ModInstallDir .. 'huds/hudDialogs.lua')

-- initialize the Hud
function hudSponsors:init(spList)	
	-- Create the backgroung overlay
	self.backgOverlay = createImageOverlay(Utils.getFilename('img/hudSponsorSel.png', AgroSponsor.ModInstallDir));
	
	-- Create the sponsor list
	self.sponsorList = spList;
	
	-- Build the overlays for sponsors
	hudSponsors:buildSponsors();
	
	-- Build the Mouse Overlay for Sponsors
	self.mspOverlay = createImageOverlay(Utils.getFilename('img/sponsorButton.png', AgroSponsor.ModInstallDir));
	
	self.mspVisible = false;
	self.mspX = 0;
	self.mspY = 0;
	self.hvSponsorName = nil;	
	
	-- set default visibility
	self.visible = false;
	self.isCancelled = false;
end
 
function hudSponsors:buildSponsors()
	self.spOverlays = {}

	local curId = 1;
	local lineID = 1;
	
	for name, sponsor in pairs(self.sponsorList) do 
		as.utils.printDebug('[hudSponsors] Building ' .. name);
	
		local spOverlay = createImageOverlay(Utils.getFilename(sponsor['Image'], AgroSponsor.ModInstallDir));
		local spLine = math.ceil(curId / hudSponsors.perLineSponsors);
		
		local spOverlayH = hudSponsors.spImgRatio;
		local spOverlayW = hudSponsors.spImgRatio;
		local spOverlayX = hudSponsors.startPosX + (0.228 * (lineID  - 1));
		local spOverlayY = hudSponsors.startPosY - (0.252 * (spLine - 1));
		
		local spOvData = {}
		spOvData['Overlay'] = spOverlay;
		spOvData['X'] = spOverlayX;
		spOvData['Y'] = spOverlayY;
		spOvData['H'] = spOverlayH;
		spOvData['W'] = spOverlayW;	
		spOvData['Ship'] = sponsor['Ship'];	
		spOvData['Reward'] = sponsor['Reward'];	
		
		as.utils.printDebug("Sponsor Builded");
		as.utils.print_r(spOvData);
		
		self.spOverlays[name] = spOvData;
	
		if curId >= hudSponsors.maxSponsors then 
			break;
		end
		
		curId = curId + 1;
		lineID = lineID + 1;
		
		if lineID > hudSponsors.perLineSponsors then 
			lineID = 1;
		end 
	end 
end 

function hudSponsors:isVisible()
	return self.visible;
end 

function hudSponsors:show()
	self.visible = true;
end 

function hudSponsors:getIsCancelled()
	return self.isCancelled;
end

function hudSponsors:hide()
	self.visible = false;
	
	-- DISABLE the mouse 
	asMouseHud:setEnabled(false);
end 

function hudSponsors:update(dt) 
	-- Check if the mouse is inside of any sponsor overlay 
	for name, data in pairs(self.spOverlays) do 
		local isMouseInside = asMouseHud:isInsideOf(data['X'], data['Y'], data['W'], data['H']);
		if isMouseInside then 
			self.mspVisible = true;
			self.mspX = data['X'];
			self.mspY = data['Y'];	
			self.hvSponsorName = name;
			break;			
		else
			self.hvSponsorName = nil;		
			self.mspVisible = false;			
		end 
	end 
end 

function hudSponsors:draw()
	if self.visible then 
		-- Render the overlay
		renderOverlay(self.backgOverlay, 0.22, 0.12, 0.75, 0.75);	

		-- Render all sponsor overlays
		for name, data in pairs(self.spOverlays) do 
			renderOverlay(data['Overlay'], data['X'], data['Y'], data['W'], data['H']);
			
			-- Render Sponsorship 
			local rewardX = data['X'] + 0.09;
			local rewardY = data['Y'] - 0.04;
			renderText(rewardX, rewardY, 0.015, ('%s'):format(g_i18n:formatMoney(data['Reward'])));
			
			local shipX = data['X'] + 0.162;
			local shipY = data['Y'] - 0.04;
			renderText(shipX, shipY, 0.017, ('%s'):format(g_i18n:formatMoney(data['Ship'])));
		end 
		
		-- Render the Sponsor Overlay 
		if self.mspVisible then 
			renderOverlay(self.mspOverlay, self.mspX, self.mspY, hudSponsors.spImgRatio, hudSponsors.spImgRatio);
		end 
		
		-- Render all the texts
		renderText(0.223, 0.846, 0.024, as.utils.getText('AGROSPONSOR_CHOOSESP')); -- TITLE
		renderText(0.245, 0.171, 0.018, as.utils.getText('AGROSPONSOR_HELPDSP')); -- Help Reward
		renderText(0.245, 0.135, 0.018, as.utils.getText('AGROSPONSOR_HELPR')); -- Help Daily Sponsorship
		renderText(0.545, 0.135, 0.018, as.utils.getText('AGROSPONSOR_EXITKEY')); -- Quit
		
		
		-- Enable the mouse 
		asMouseHud:setEnabled(true);
	end
end 

function hudSponsors:deleteMap()	
end;

function hudSponsors:loadMap(name)
end;

function hudSponsors:keyEvent(unicode, sym, modifier, isDown)
	if sym == Input.KEY_q and isDown == true and self.visible then
		-- User Cancelled the selection 
		as.utils.printDebug('Player has canceled the sponsor selection');
		self:hide();
		self.isCancelled = true;
	end;
end;

function hudSponsors:mouseEvent(posX, posY, isDown, isUp, button)
	if isDown and self.hvSponsorName ~= nil and self.visible then
		self.selectedSponsor = self.sponsorList[self.hvSponsorName];
						
		local text = as.utils.getText('AGROSPONSOR_YESNODSPTXT'):format(self.selectedSponsor['Title']);
		local title = as.utils.getText('AGROSPONSOR_YESNODSP');
		asDialogs:showYesNo(title, text, self.saveSelectedSponsor);
	end 
end;

function hudSponsors:saveSelectedSponsor(yes)	
	if yes then
		as.utils.printDebug('Player has selected a sponsor: ');
		as.utils.print_r(hudSponsors.selectedSponsor);
		
		AgroSpManager:saveSponsor(hudSponsors.selectedSponsor);
		hudSponsors:hide();
	end 
	
	g_gui:showGui('');
end;