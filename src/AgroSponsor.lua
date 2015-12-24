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


-- Load the Depedencies
source(AgroSponsor.ModInstallDir .. 'logics/Messages.lua')
source(AgroSponsor.ModInstallDir .. 'logics/Utils.lua')
source(AgroSponsor.ModInstallDir .. 'logics/Sponsors.lua')
source(AgroSponsor.ModInstallDir .. 'logics/Clock.lua')
source(AgroSponsor.ModInstallDir .. 'huds/hudSponsors.lua')

function AgroSponsor:loadMap(name)
	print('[AgroSponsor] Loading ')
	
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
	
	self.isNight = not g_currentMission.environment.isSunOn;
	
	-- Debug 
	print('[AgroSponsor] Save directory ' .. self.saveGameDir);
	print('[AgroSponsor] Save file ' .. AgroSponsor.firstLoadFile);
	
	-- Load the Clock
	asClock:init();
	
	-- Load the Sponsor List
	AgroSpManager:load();
	local spList = AgroSpManager:buildSponsorList();
	
	-- Load the Sponsor Huds
	hudSponsors:init(spList);
	
	-- Initialize the mouse cursor
	asMouseHud:init();
	
	-- Add huds to event listener 
	addModEventListener(hudSponsors);

	-- Check if is the first time	
	AgroSponsor:checkIsSaved();
	
	-- Check if the player has a sponsor selected
	if not AgroSpManager:hasSponsorSelected() and self.gameIsSaved == 1 then 
		-- Render the Selection Hud 			
		hudSponsors:show();
	elseif AgroSpManager:hasSponsorSelected() and self.gameIsSaved == 1 then 
		-- Load the Sponsor
		AgroSpManager:loadSponsor();
		
		as.utils.printDebug("Current Sponsor: ");
		as.utils.print_r(AgroSpManager.Sponsor);
	end 
	
	print('[AgroSponsor] Loaded ')
end;

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
	
	if not AgroSpManager:hasSponsorSelected() and self.gameIsSaved == 1 then 
		-- Render the Selection Hud 			
		hudSponsors:show();
	end
end; 

function AgroSponsor:keyEvent(unicode, sym, modifier, isDown)
end;

function AgroSponsor:mouseEvent(posX, posY, isDown, isUp, button)
end;

function AgroSponsor:draw()
end;

function AgroSponsor:deleteMap()	
end;

addModEventListener(AgroSponsor);