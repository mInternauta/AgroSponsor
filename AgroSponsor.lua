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
AgroSponsor.isNight = false
AgroSponsor.gameIsSaved = 0
AgroSponsor.firstLoadFile = ''
AgroSponsor.firstLoad = 0

MinSponsorMoney = 5000
MaxSponsorMoney = 875050

-- the possibility (a percentage) of the player receives a sponsorship in the day.
SponsorChance = 15

-- Load the Messages
source(AgroSponsor.ModInstallDir .. 'Messages.lua')
source(AgroSponsor.ModInstallDir .. 'Utils.lua')

function AgroSponsor:asCreateID() 
	local spFile = io.open(AgroSponsor.firstLoadFile, 'w')
	
	if spFile ~= nil then
		spFile:write('1')
		spFile:close()
		AgroSponsor.gameIsSaved = 1
	else 
		AgroSponsor.gameIsSaved = 0
	end 
end 

function AgroSponsor:asSpinReward()	
	-- Take a chance for Sponsors
	local chance = math.random(1, 100);
	local mxSpMoney = MaxSponsorMoney;
	
	-- If is the first load and the game is saved, give a sponsorship 
	if AgroSponsor.firstLoad == 1 and AgroSponsor.gameIsSaved == 1 then 
		chance = SponsorChance		
		
		-- lower the value to 40% of the max reward
		mxSpMoney = MaxSponsorMoney * 0.40; 
		
		AgroSponsor.firstLoad = 0
	end
	
	if chance <= SponsorChance then 
		print('[AgroSponsor] Ohhhwww Baby, thats is sweet!');		
		
		-- Take the reward
		local reward = math.random(MinSponsorMoney, mxSpMoney);
		
		g_currentMission:addSharedMoney(reward, 'Sponsors');
		
		AgroMessages:show(reward);
	else 
		print('[AgroSponsors] Not this time baby ' .. chance);
	end 
end 

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
	
	-- Check if is the first time	
	if fileExists(self.firstLoadFile) then 
		self.firstLoad = 0
		self.gameIsSaved = 1
	else
		print('[AgroSponsor] First Load ')
		self.firstLoad = 1
		
		-- Try create the file 
		self.asCreateID();
	end 
	
	print('[AgroSponsor] Loaded ')
end;

function AgroSponsor:update(dt)
	-- If is first load, try and the file no exists try to create 
	if self.firstLoad == 1 and self.gameIsSaved == 0 then 
		self.asCreateID();
	end
	
	if g_currentMission.environment.isSunOn == false and self.isNight == false then
		self.isNight = true;
		print('[AgroSponsor] Is Night Baby!');
	elseif self.isNight == true and g_currentMission.environment.isSunOn == true then 
		print('[AgroSponsor] Is sunset baby, lets roll!');
		self.isNight = false;
		self.asSpinReward();
	end
	
	if self.firstLoad == 1 and self.gameIsSaved == 1 then
		self.asSpinReward();
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