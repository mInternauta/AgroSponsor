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
AgroPlayerProfile = {}

-- Player Profile
AgroPlayerProfile.Profile = {};

-- Constants
-- Factor which will be multiplied by the level of the player and added to the sponsor reward.
AS_PLAYER_RWFACTOR = 0.03;

-- Amount of experience needed for next level
AS_PLAYER_PLVEXP = 12;

local AgroPlayerProfile_mt = Class(AgroPlayerProfile);

-- Dependencies
source(AgroSponsor.ModInstallDir .. 'libs/tableSerializer.lua')

-- Give Experience to the Player 
function AgroPlayerProfile:giveExp(expCount)
	self.Profile.Exp = self.Profile.Exp + expCount;
end

-- Give Levels to The Player
function AgroPlayerProfile:giveLevel(levels)
	local totExp = AS_PLAYER_PLVEXP * levels;
	self:giveExp(totExp);
end 

-- Set player to the level 
function AgroPlayerProfile:setLevel(level)
	local totExp = AS_PLAYER_PLVEXP * levels;
	self.Profile.Exp = totExp;
end 

-- Calculates the Player level by the experience
function AgroPlayerProfile:getLevel()
	local curLevel = math.floor(self.Profile.Exp / AS_PLAYER_PLVEXP);
	return curLevel;
end 

-- Get current Player Experience
function AgroPlayerProfile:getExperience()
	return self.Profile.Exp;
end 

function AgroPlayerProfile:getNextLevelExp()
	local nextLevel = self:getLevel() + 1;
	return nextLevel * AS_PLAYER_PLVEXP;
end 

function AgroPlayerProfile:getExperiencePerLevel()
	return AS_PLAYER_PLVEXP;
end 

function AgroPlayerProfile:getMissingExp()
	local toTheNextLevel = self:getNextLevelExp();
	local curRemainExp = toTheNextLevel - self:getExperience();
	return AS_PLAYER_PLVEXP - curRemainExp;
end 

-- Calculates the Player Reward by The Current Level
function AgroPlayerProfile:calcReward(rewardBase)
	local curLevel = self:getLevel();
	local levelFactor = AS_PLAYER_RWFACTOR * curLevel;
	local rewardAdd = rewardBase * levelFactor;
	
	return math.ceil(rewardBase + rewardAdd);
end 

-- Initialize the Player Class
function AgroPlayerProfile:init() 
	self:load();
	
	if self.Profile == nil then 
		self.Profile = {}
		self.Profile.Exp = 0;
		self.Profile.Stats = {};
	end 
	
	self:autoSave();
end 

--- Load the Player Profile
function AgroPlayerProfile:load()
	local playerFile = AgroSponsor.saveGameDir .. '/asPlayer.data';
	local player = nil;
	
	if fileExists(playerFile) then
		local xml = loadXMLFile("ASPlayer", playerFile);
		local sData = getXMLString(xml, "Player.Data");
		player = table.deserialize(sData);
	end 
	
	self.Profile = player;
end 

-- Save the Player Profile 
function AgroPlayerProfile:save()
	if AgroSponsor:isGameSaved() then 
		local playerFile = AgroSponsor.saveGameDir .. '/asPlayer.data';
		local xml = nil;
			
		if fileExists(playerFile) then
			xml = loadXMLFile("ASPlayer", playerFile);
		else 
			xml = createXMLFile("ASPlayer", playerFile, "Player");
		end 
		
		local data = table.serialize(self.Profile);
		
		setXMLString(xml, "Player.Data", data);
		saveXMLFile(xml);
		delete(xml);
	end;
end 


-- AutoSave the Player Profile 
function AgroPlayerProfile:autoSave() 
	if self.Profile ~= nil then 
		self:save();
	end 
end 