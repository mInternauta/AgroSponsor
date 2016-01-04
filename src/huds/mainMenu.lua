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
AgroMainMenu = {}


source(AgroSponsor.ModInstallDir .. 'huds/hudPlayerProfile.lua')
source(AgroSponsor.ModInstallDir .. 'huds/hudRentMenu.lua')

-- Main Menu  Actions
function AgroMainMenu:chooseSponsor()
	AgroMainMenu:hideMenu();
	hudSponsors:show();
end 

function AgroMainMenu:myProfile()
	AgroMainMenu:hideMenu();
	AgroPlayerProfHud:show();
end

function AgroMainMenu:rentMenu()
	AgroMainMenu:hideMenu();
	AgroRentMenuHud:show();
end

-- Main Menu HUD 

function AgroMainMenu:hideMenu() 
	self.MainMenu:hide();
end 

function AgroMainMenu:loadMap(name)
end; 

function AgroMainMenu:load() 
	as.utils.printDebug("Creating a the Main Menu: ");		
	self.MainMenu = createMenuInstance(as.utils.getText('AGROSPONSOR_MAINMENUTITLE'));			
	self.MainMenu:addItem('asMMProfile', as.utils.getText('AGROSPONSOR_MMPROFILE'), AgroMainMenu.myProfile);		
	self.MainMenu:addItem('asMMSponsor', as.utils.getText('AGROSPONSOR_MMSPONSOR'), AgroMainMenu.chooseSponsor);	
	self.MainMenu:addItem('asMMRent', as.utils.getText('AGROSPONSOR_RENTTITLE'), AgroMainMenu.rentMenu);	
	
	AgroPlayerProfHud:init();
	AgroRentMenuHud:init();
	
	addModEventListener(self.MainMenu);
end; 

function AgroMainMenu:keyEvent(unicode, sym, modifier, isDown) 
	if bitAND(modifier, Input.MOD_CTRL) > 0 and isDown and sym == Input.KEY_m and self.MainMenu ~= nil then 
		as.utils.printDebug("Showing the Main Menu");
		self.MainMenu:show();
	end 
end;

function AgroMainMenu:mouseEvent(posX, posY, isDown, isUp, button)
end;

function AgroMainMenu:draw()
end;

function AgroMainMenu:deleteMap()	
end;

function AgroMainMenu:update(dt)
end;

addModEventListener(AgroMainMenu);