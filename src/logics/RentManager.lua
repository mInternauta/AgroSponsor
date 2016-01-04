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

-- Constants
AgroRentManager.percFromPrice = 0.020;
AgroRentManager.percDescFromSponship = 0.015;
AgroRentManager.percFromUpkeep = 0.025;
AgroRentManager.percForExp = 0.0024;


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
		
		dailyPrice = math.ceil(dailyPrice);
		
		local expPoints = math.ceil(dailyPrice * AgroRentManager.percForExp);
		
		rentItem["Store"] = storeItem;
		rentItem["IsSponsored"] = isSponsorProduct;
		rentItem["Price"] = dailyPrice;	
		rentItem["Exp"] = expPoints;	
	end
	
	return rentItem;
end 
