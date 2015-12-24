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
AgroSpManager = {}
AgroSpManager.sponsors = {}

-- the possibility (a percentage) of the player receives a sponsorship in the day.
SponsorChance = 20

local AgroSpManager_mt = Class(AgroSpManager);

-- Depedencies
source(AgroSponsor.ModInstallDir .. 'libs/tableSerializer.lua')

function AgroSpManager:rollReward()
	local sponsor = AgroSpManager.Sponsor;
		
	as.utils.printDebug("Is a new day Baby lets roll!");
	
	if sponsor ~= nil then
		local ship = sponsor['Ship'];
		local maxReward = sponsor['Reward'];
		local minReward = maxReward * 0.6;
		
		local reward = math.random(minReward, maxReward);
		local chance = math.random(1, 100);
		
		if chance <= SponsorChance then
			AgroMessages:show(reward, sponsor['Title']);
			g_currentMission:addSharedMoney(reward, 'others');	
		end
		
		as.utils.printDebug("[Daily Sponsorship] " .. ship);
		g_currentMission:addSharedMoney(ship, 'others');
	end 
end 

-- Check if is the play already selected the sponsors
function AgroSpManager:hasSponsorSelected() 
	local sponsorFile = AgroSponsor.saveGameDir .. '/sponsor.data';
	
	if fileExists(sponsorFile) then 
		return true;
	else
		return false;
	end
end 

-- Load the sponsor 
function AgroSpManager:loadSponsor()
	local sponsorFile = AgroSponsor.saveGameDir .. '/sponsor.data';
	local sponsor = nil;
	
	if fileExists(sponsorFile) then
		local xml = loadXMLFile("SponsorXml", sponsorFile);
		local sData = getXMLString(xml, "Sponsor.Data");
		sponsor = table.deserialize(sData);
	end 
	
	self.Sponsor = sponsor;
end

-- Save the sponsor to the savegame 
function AgroSpManager:saveSponsor(sponsor)
	local sponsorFile = AgroSponsor.saveGameDir .. '/sponsor.data';
	local xml = nil;
	
	if fileExists(sponsorFile) then
		xml = loadXMLFile("SponsorXml", sponsorFile);
	else 
		xml = createXMLFile("SponsorXml", sponsorFile, "Sponsor");
	end 
	
	local data = table.serialize(sponsor);
	
	setXMLString(xml, "Sponsor.Data", data);
	saveXMLFile(xml);
	delete(xml);
	
	self:loadSponsor();
end 

-- Select random sponsors 
function AgroSpManager:buildSponsorList() 
	local spList = {}
	
	as.utils.printDebug('Buildind Sponsor List ');
	
	for name, sponsor in pairs(AgroSpManager.sponsors) do 
		local chance  = math.random(0, 10);
		if chance <= 7 then 
			as.utils.printDebug('Selected Sponsor: ' .. name);
			
			local spData = sponsor;					
			
			-- Generate the Sponsor daily sponsorship
			local maxSpShip = spData['MaxShip'];
			local minSpShip = maxSpShip * 0.28;
			local spShip = math.ceil(math.random(minSpShip, maxSpShip));
			
			-- Generate the sponsor complete reward
			local maxSpReward = spData['MaxReward'];
			local minSpReward = maxSpReward * 0.28;
			local spReward = math.ceil(math.random(minSpReward, maxSpReward));
			
			-- Add the new value to sponsor data
			spData['Reward'] = spReward;
			spData['Ship'] = spShip;
			
			spList[name] = spData;
		end 
	end 

	return spList;
end 

-- Load the Sponsor Configuration from the XML
function AgroSpManager:load() 
	local xmlPath = AgroSponsor.ModInstallDir .. 'data/Sponsors.xml';
	local spXml = loadXMLFile('asSponsors', xmlPath);
	
	as.utils.printDebug('Loading Sponsors: ' .. xmlPath);
	
	if hasXMLProperty(spXml, 'Sponsors.Avaliable') and hasXMLProperty(spXml, 'Sponsors.Items') then
		local avaliableSps = getXMLString(spXml, 'Sponsors.Avaliable');
		
		for spName in string.gmatch(avaliableSps, '([^|]+)') do
			as.utils.printDebug('Sponsor ' .. spName);
			local key = 'Sponsors.Items.' .. spName;
			
			if hasXMLProperty(spXml, key) then 
				local spTitle = getXMLString(spXml, key .. '#title');
				local spMaxShip = getXMLInt(spXml, key .. '#maxShip');
				local spMaxReward = getXMLInt(spXml, key .. '#maxReward');
				local spImg = getXMLString(spXml, key .. '#image');
				local spData = {}
				
				as.utils.printDebug('- Title: ' .. spTitle);
				as.utils.printDebug('- MaxShip: ' .. spMaxShip);
				as.utils.printDebug('- MaxReward: ' .. spMaxReward);
				as.utils.printDebug('- Image: ' .. spImg);
				
				spData['Title'] = spTitle;
				spData['MaxShip'] = spMaxShip;
				spData['MaxReward'] = spMaxReward;
				spData['Image'] = spImg;
				self.sponsors[spName] = spData;
			else
				as.utils.printDebug('Not found: ' .. key);
			end ;
		end;
	else 
		as.utils.printDebug('Invalid Sponsors.xml, cant load the sponsors!');
	end ;
	
	-- Register the Clock Event
	asClock:registerNewDayEvent('asSponsorRoll', self.rollReward);
end

-- Prevent the savegame from removind the sponsor.id file
function AgroSpManager:autoSave()
	as.utils.printDebug("SAVING");
	if AgroSpManager.Sponsor ~= nil then 
		as.utils.printDebug("SAVING SPONSOR");
		AgroSpManager:saveSponsor(AgroSpManager.Sponsor);
	end 
end 
g_careerScreen.saveSavegame = Utils.appendedFunction(g_careerScreen.saveSavegame, AgroSpManager.autoSave);