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
AgroSponsor = {}
AgroSponsor.ModInstallDir = g_currentModDirectory;
AgroSponsor.saveGameDir = ''
AgroSponsor.gameIsSaved = 0
AgroSponsor.spSelDayCount = 0;

-- Load the Dependencies
source(AgroSponsor.ModInstallDir .. 'logics/Messages.lua')
source(AgroSponsor.ModInstallDir .. 'logics/Utils.lua')
source(AgroSponsor.ModInstallDir .. 'logics/Sponsors.lua')
source(AgroSponsor.ModInstallDir .. 'logics/Clock.lua')
source(AgroSponsor.ModInstallDir .. 'logics/Player.lua')
source(AgroSponsor.ModInstallDir .. 'logics/RentManager.lua')
source(AgroSponsor.ModInstallDir .. 'shell/basicShell.lua')

source(AgroSponsor.ModInstallDir .. 'huds/hudSponsors.lua')
source(AgroSponsor.ModInstallDir .. 'huds/hudMenu.lua')
source(AgroSponsor.ModInstallDir .. 'huds/mainMenu.lua')

function AgroSponsor:loadMap(name)
	print('[AgroSponsor] Loading ')
	
	-- Check for the directory
	AgroSponsor:checkDirectory();
	
	-- Debug 
	print('[AgroSponsor] Save directory ' .. self.saveGameDir);
	print('[AgroSponsor] Save file ' .. AgroSponsor.firstLoadFile);
		
	-- Load the Clock
	asClock:init();
	
	-- Load the Player Profile
	AgroPlayerProfile:init();
	
	-- Load the Sponsor List
	AgroSpManager:load();
	
	-- Load all the rents 
	AgroRentManager:load();
	
	-- Load the GUIs
	self:loadGUI();
	
	-- Load the Shell
	AgroShell:load();
	
	-- Add the Sponsor List to be reload every day in the game 
	asClock:registerNewDayEvent('asSponsorList', AgroSponsor.loadSponsorSelectionEvent);
	asClock:registerNewDayEvent('asRent', AgroSponsor.checkRents);
	
	-- Load the Sponsor List 
	 AgroSponsor:loadSponsorSelection();
		
	-- Add huds to event listener 
	addModEventListener(hudSponsors);

	-- Check the savegame 
	self:checkSavegame()
	
	print('[AgroSponsor] Loaded ')
end;

function AgroSponsor:checkRents()
	AgroRentManager:checkRents();
end 

function AgroSponsor:loadSponsorSelectionEvent()
	AgroSponsor.spSelDayCount = AgroSponsor.spSelDayCount + 1;
	
	if AgroSponsor.spSelDayCount == 5 then -- Do it every 5 days 
		AgroSponsor:loadSponsorSelection();
		AgroSponsor.spSelDayCount = 0;
	end 
end

function AgroSponsor:loadSponsorSelection()
	local spList = AgroSpManager:buildSponsorList();	
	-- Load the Sponsor Huds
	hudSponsors:init(spList);	 
end 

function AgroSponsor:checkDirectory()
	-- Check for the Savegame Directory
	if g_server ~= nil then
		local savegameDir;
		
		if g_currentMission.missionInfo.savegameDirectory then
			savegameDir = g_currentMission.missionInfo.savegameDirectory;
		end;
		
		if not savegameDir and g_careerScreen.currentSavegame and g_careerScreen.currentSavegame.savegameIndex then 
			savegameDir = ('%ssavegame%d'):format(getUserProfileAppPath(), g_careerScreen.currentSavegame.savegameIndex);
		end;
		
		if not savegameDir and g_currentMission.missionInfo.savegameIndex ~= nil then
			savegameDir = ('%ssavegame%d'):format(getUserProfileAppPath(), g_careerScreen.missionInfo.savegameIndex);
		end;
		
		self.saveGameDir = savegameDir;
		self.firstLoadFile = savegameDir .. '/sponsorship.id';
	end
end 

function AgroSponsor:checkSavegame()
	-- Check if is the first time	
	AgroSponsor:checkIsSaved();
	
	-- Check if the player has a sponsor selected
	if not AgroSpManager:isSponsorSaved() then 
		-- Render the Selection Hud 			
		hudSponsors:show();
	elseif AgroSpManager:isSponsorSaved() and self.gameIsSaved == 1 then 
		-- Load the Sponsor
		AgroSpManager:loadSponsor();
		
		as.utils.printDebug("Current Sponsor: ");
		as.utils.print_r(AgroSpManager.Sponsor);
	end 	
end 

function AgroSponsor:loadGUI()	
	-- Load the Sponsor Selection Hud
	AgroSponsor:loadSponsorSelection()

	-- Initialize the mouse cursor
	asMouseHud:init();
	
	-- Create the Main Menu
	AgroMainMenu:load() ;
end 

function AgroSponsor:isGameSaved()
	self:checkIsSaved();
	if self.gameIsSaved == 1 then
		return true;
	else 
		return false;
	end 
end 

function AgroSponsor:checkIsSaved()
	-- Check if is the first time	
	if fileExists(AgroSponsor.saveGameDir .. '/careerSavegame.xml') then
		self.gameIsSaved = 1;
	else
		self.gameIsSaved = 0;
	end 	
end 

function AgroSponsor:update(dt)
	AgroSponsor:checkIsSaved();
	asClock:update(g_currentMission.environment);
	
	if not AgroSpManager:hasSponsorSelected() and hudSponsors:getIsCancelled() == false and hudSponsors:isVisible() == false then 
		-- Render the Selection Hud 			
		hudSponsors:show();
	end

	if AgroSpManager:isSponsorSaved() == false then 
		-- Auto save the Sponsor
		AgroSpManager:autoSave();
	end;
	
	AgroRentManager:update();
end; 

function AgroSponsor:keyEvent(unicode, sym, modifier, isDown)
end;

function AgroSponsor:mouseEvent(posX, posY, isDown, isUp, button)
end;

function AgroSponsor:draw()
end;

function AgroSponsor:deleteMap()	
end;

function AgroSponsor:autoSave()
	if AgroSponsor:isGameSaved() then	
		 AgroPlayerProfile:autoSave();
		 AgroSpManager:autoSave();
		 AgroRentManager:autoSave();
	end;
end;

g_careerScreen.saveSavegame = Utils.appendedFunction(g_careerScreen.saveSavegame, AgroSponsor.autoSave);
addModEventListener(AgroSponsor);