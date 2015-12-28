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
AgroShell = {}
local AgroShell_mt = Class(AgroShell);

-- All other objects must be loaded before the console, this script doesn't load the previous dependencies.
-- Load the Console 
function AgroShell:load()
	-- Sponsor Commands
	addConsoleCommand("asCurrentSponsor", "Dumps the current selected sponsor", "currentSponsor", self);
	addConsoleCommand("asSetSpHud", "Show/Hide the sponsor hud", "setSponsorHud", self);
	addConsoleCommand("asRollReward", "Spin the Reward of the current sponsor", "spinReward", self);
	
	-- Profile Commands
	addConsoleCommand("asPlayerLevel", "Get current player level", "getPlayerLevel", self);
	addConsoleCommand("asPlayerExp", "Get current player experience", "getPlayerExp", self);
	addConsoleCommand("asGiveExp", "Give experience to the player", "givePlayerExp", self);
	addConsoleCommand("asGiveLevels", "Give levels to the player", "givePlayerLvls", self);
	addConsoleCommand("asSetLevel", "Set the player level", "setPlayerLvl", self);
	addConsoleCommand("asDumpProfile", "Dumps the player profile", "dumpPlayerProfile", self);
	addConsoleCommand("asCalcReward", "Calculate the reward based on a number", "calcPlayerReward", self);
end 

---------------------------------------------------------------------------------------- ==
-- Sponsor Commands 
function AgroShell:currentSponsor() 
	if AgroSpManager:hasSponsorSelected() then 
		as.utils.printDebug("Selected sponsor: ");
		as.utils.print_r(AgroSpManager.Sponsor);
	else 	
		as.utils.printDebug("The player has not selected the sponsor!");
	end 
end 

function AgroShell:setSponsorHud(state)
	if state == "1" then
		hudSponsors:show();
	else 
		hudSponsors:hide();
	end 
end 

function AgroShell:spinReward() 
	AgroSpManager:rollReward();
end 

---------------------------------------------------------------------------------------- ==
-- Player Profile Commands
function AgroShell:getPlayerLevel()
	as.utils.printDebug("Current Player Level: " .. AgroPlayerProfile:getLevel());
end;

function AgroShell:getPlayerExp()
	as.utils.printDebug("Current Player Experience: " .. AgroPlayerProfile:getExperience());
end;

function AgroShell:givePlayerExp(expNum)
	local expN = tonumber(expNum);
	as.utils.printDebug("Giving to player: " .. expN .. " exp points..");
	
	AgroPlayerProfile:giveExp(expN);
end 

function AgroShell:givePlayerLvls(lvlNum)
	local lvls = tonumber(lvlNum);
	as.utils.printDebug("Giving to player: " .. lvls .. " levels..");
	
	AgroPlayerProfile:giveLevel(lvls);
end 

function AgroShell:setPlayerLvl(lvlNum)
	local lvl = tonumber(lvlNum);
	as.utils.printDebug("Set player to the " .. lvl .. " level");
	
	AgroPlayerProfile:setLevel(lvl);
end 

function AgroShell:dumpPlayerProfile()
	as.utils.printDebug("Selected player profile: ");
	as.utils.print_r(AgroPlayerProfile.Profile);
end 

function AgroShell:calcPlayerReward(rewBase)
	as.utils.printDebug("Calculating the reward based on: " .. rewBase);
	local reward = AgroPlayerProfile:calcReward(rewBase);
	as.utils.printDebug("Calculated reward: " .. reward);
end