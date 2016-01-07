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
AgroRentManager = {}
AgroRentManager.Rents = {}

-- Constants
AgroRentManager.percFromPrice = 0.028;
AgroRentManager.percDescFromSponship = 0.015;
AgroRentManager.percFromUpkeep = 0.03;
AgroRentManager.percForExp = 0.002;


--- Load the Rents Data
function AgroRentManager:load()
	AgroRentManager.ActivedRents = {};	
	AgroRentManager.Rents = {};	

	local rentFile = AgroSponsor.saveGameDir .. '/asRents.data';
	local data = {};
	
	if fileExists(rentFile) then
		local xml = loadXMLFile("ASRents", rentFile);
		local sData = getXMLString(xml, "Rents.Data");
		data = table.deserialize(sData);
	end 
	
	if data ~= nil then 
		self.Rents = data;
	end 
end 

-- Save the Rents Data 
function AgroRentManager:save()
	if AgroSponsor:isGameSaved() then 
		local rentFile = AgroSponsor.saveGameDir .. '/asRents.data';
		local xml = nil;
			
		if fileExists(rentFile) then
			xml = loadXMLFile("ASRents", rentFile);
		else 
			xml = createXMLFile("ASRents", rentFile, "Rents");
		end 
		
		local data = table.serialize(self.Rents);
		
		setXMLString(xml, "Rents.Data", data);
		saveXMLFile(xml);
		delete(xml);
	end;
end 

-- AutoSave
function AgroRentManager:autoSave() 
	if self.Rents ~= nil then 
		self:save();
	end 
end 

function AgroRentManager:checkRents()	
	for rentID, rentObj in pairs(self.ActivedRents) do 
		local rent = self.Rents[rentID];
		
		if rent ~= nil then 			
			local rentPrice = rent['Price']			
			local vehicle = rentObj['Vehicle']
			
			if g_currentMission.missionStats.money > rentPrice then 	
				g_currentMission:addSharedMoney(-rentPrice, "other");
			else 
				AgroRentManager:removeRent(rentID, vehicle);
				
				-- Show the message 
				local text = as.utils.getText('AGROSPONSOR_RENTEXPIRED');
		
				text = string.gsub(text, '/NAME', rent['Name']);
				AgroMessages:show(text, as.utils.getText('AGROSPONSOR_RENT'));
			end 
		else 
			self.ActivedRents[rentID] = nil;
			vehicle.asHasRent = false;
			vehicle.asRent = nil; 
		end 
	end
end 

function AgroRentManager:update() 
	for rentId, rent in pairs(self.Rents) do 
		local activedRent = self.ActivedRents[rentId];
		
		if activedRent == nil then 
			self.Rents[rentId]["Expired"] = true;
		end 
	end 
end 

function AgroRentManager:remove(rentId)
	if self.ActivedRents[rentId] ~= nil then 
		AgroRentManager:removeRent(rentId, self.ActivedRents[rentId]['Vehicle']);
	else 	
		-- Set the rent as deactivated 
		self.Rents[rentID]['Expired'] = true;
	end 
end 

function AgroRentManager:removeRent(rentID, vehicle)								
	-- Set the rent as deactivated 
	self.Rents[rentID]['Expired'] = true;

	g_currentMission:removeVehicle(vehicle, true);
	self.ActivedRents[rentID] = nil;
end 

-- Rent a store item
function AgroRentManager:rent(rentData)
	local rentDailyValue = rentData['Price']
	local rentExp = rentData['Exp']
	local rentID = as.utils.randomID();
	
	if g_currentMission.missionStats.money > rentDailyValue then 	
		-- Load and place the vehicle 	
		local vehicle = g_currentMission:loadVehicle(rentData['Store']['xmlFilename'], 1, 1, 1, 0, true);		
		
		local x, y, z, place, width, offset = PlacementUtil.getPlace(g_currentMission.loadSpawnPlaces, vehicle.sizeWidth, vehicle.sizeLength, vehicle.widthOffset, vehicle.lengthOffset, g_currentMission.usedLoadPlaces);
		if x ~= nil then
			local yRot = Utils.getYRotationFromDirection(place.dirPerpX, place.dirPerpZ);
			PlacementUtil.markPlaceUsed(g_currentMission.usedLoadPlaces, place, width);
			vehicle:setRelativePosition(x, offset, z, yRot);
		end;
		
		vehicle.asRent = rentID;
		vehicle.asHasRent = true;
		
		-- Give the Player Exp
		AgroPlayerProfile:giveExp(rentExp);
		
		-- Remove the Money from the Player 
		g_currentMission:addSharedMoney(-rentDailyValue, "other");
		
		as.utils.print_r(self.Rents);
		
		-- Save the Rent to the List 	
		self.Rents[rentID] = {};
		self.Rents[rentID]['ID'] = rentID;
		self.Rents[rentID]['Price'] = rentDailyValue;
		self.Rents[rentID]['Expired'] = false;
		self.Rents[rentID]['Name'] = rentData['Store']['brand'] .. " " .. rentData['Store']['name'];
		
		self:save();
		
		-- Show the message	
		local text = as.utils.getText('AGROSPONSOR_RENTMSG');
		
		text = string.gsub(text, '/NAME', self.Rents[rentID]['Name']);
		text = string.gsub(text, '/PRICE', as.utils.toMoneyString(rentDailyValue));
		
		AgroMessages:show(text, as.utils.getText('AGROSPONSOR_RENT'));
	end 
end 

-- Create the rent information from a store item 
function AgroRentManager:create(storeId)
	local storeItem = StoreItemsUtil.storeItems[storeId];
	local rentItem = {}
		
	if storeItem ~= nil then 	
		local price = storeItem["price"];
		local upkeep = storeItem["dailyUpkeep"];
		local currentSponsor = AgroSpManager.Sponsor;
		local isSponsorProduct = false;
		
		if currentSponsor ~= nil then 
			if string.upper(currentSponsor['Title']) == string.upper(storeItem['brand']) then 
				isSponsorProduct = true;
			end
		end 
		
		local dailyPrice = math.floor(price * AgroRentManager.percFromPrice);
		local dailyKeep = math.ceil(upkeep * AgroRentManager.percFromUpkeep);
		dailyPrice = dailyPrice + dailyKeep;
		
		if isSponsorProduct then 
			local descPrice = dailyPrice * AgroRentManager.percDescFromSponship;
			dailyPrice = dailyPrice - descPrice;
		end 
		
		dailyPrice = dailyPrice - (21 * AgroPlayerProfile:getLevel());
		
		dailyPrice = math.ceil(dailyPrice);		
		
		local expPoints = dailyPrice * AgroRentManager.percForExp;
		expPoints = (0.5 * AgroPlayerProfile:getLevel());
		
		expPoints = math.ceil(expPoints);
		
		rentItem["Store"] = storeItem;
		rentItem["IsSponsored"] = isSponsorProduct;
		rentItem["Price"] = dailyPrice;	
		rentItem["Exp"] = expPoints;	
	end
	
	return rentItem;
end 

-- overwrite Vehicle.lua to add rent properties to other vehicles
local vehicleOldLoadFinished = Vehicle.loadFinished;
Vehicle.loadFinished = function (self, i3dNode, arguments)
	vehicleOldLoadFinished(self, i3dNode, arguments);
	
	if self.asRent ~= nil then
		self.asHasRent = true;
	else 
		self.asHasRent = false;
	end;
end;

-- overwrite the Vehicle Save and Load 
local vehicleOldGetSaveAttributesAndNodes = Vehicle.getSaveAttributesAndNodes;
Vehicle.getSaveAttributesAndNodes = function (self, nodeIdent)
	local attributes, nodes = vehicleOldGetSaveAttributesAndNodes(self, nodeIdent);
	if self.asRent ~= nil then
		attributes = attributes .. ' asRent="'.. self.asRent ..'"';
	end;
	return attributes, nodes;
end;

local vehicleOldLoadFromAttributesAndNodes = Vehicle.loadFromAttributesAndNodes;
Vehicle.loadFromAttributesAndNodes = function (self, xmlFile, key, resetVehicles)
	local asRent = getXMLString(xmlFile, key.."#asRent");
	if asRent ~= nil then
		self.asRent = asRent;
	end;
	return vehicleOldLoadFromAttributesAndNodes(self, xmlFile, key, resetVehicles);
end;

-- overwrite the Vehicle update
local vehicleOldUpdate = Vehicle.update;
Vehicle.update = function(self, dt)
	vehicleOldUpdate(self, dt);
	if self.asHasRent then 
		local rentId = self.asRent;
		AgroRentManager.ActivedRents[rentId] = {};			
		AgroRentManager.ActivedRents[rentId]['Vehicle'] = self;		
		AgroRentManager.ActivedRents[rentId]['ID'] = rentID;		
	end 
end 

-- fix, to make sure it is impossible to sell a rent vehicle
local gShowGUIOverwritten = g_gui.showGui;
g_gui.showGui = function(self, guiName)
	if guiName == "ShopScreen" then
		self.vehiclesListChanged = true;
		self.vehiclesListRemovedVehicles = {}
		local numRemoved = 0;
		for a=1, table.getn(g_currentMission.vehicles) do
			local vehicle = g_currentMission.vehicles[a-numRemoved];
			if vehicle.asRent ~= nil then
				table.insert(self.vehiclesListRemovedVehicles, vehicle);
				table.remove(g_currentMission.vehicles, a-numRemoved);
				numRemoved = numRemoved + 1;
			end;
		end;
	elseif self.vehiclesListChanged ~= nil and self.vehiclesListChanged then
		self.vehiclesListChanged = false;
		for a=1, table.getn(self.vehiclesListRemovedVehicles) do
			table.insert(g_currentMission.vehicles, self.vehiclesListRemovedVehicles[a]);
		end;
		self.vehiclesListRemovedVehicles = nil;
	end;
	return gShowGUIOverwritten(self, guiName);
end;

local onCreateVehicleSeelingPoint = VehicleSellingPoint.onCreate;
VehicleSellingPoint.onCreate = function(self, id)
	onCreateVehicleSeelingPoint(self, id);
	self.rentVehiclesModVehiclesInTrigger = {}
	g_currentMission.vehicleSellingPointTriggerRV = self;
end;

local sellTriggerCallback = VehicleSellingPoint.sellAreaTriggerCallback;
VehicleSellingPoint.sellAreaTriggerCallback = function(self, triggerId, otherId, onEnter, onLeave, onStay, otherShapeId)
	local vehicle = g_currentMission.nodeToVehicle[otherId];
	if onEnter then
		self.rentVehiclesModVehiclesInTrigger[vehicle] = true;
	elseif onLeave then
		self.rentVehiclesModVehiclesInTrigger[vehicle] = nil;
	end;
	return sellTriggerCallback(self, triggerId, otherId, onEnter, onLeave, onStay, otherShapeId);
end;