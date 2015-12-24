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
asMouseHud = {}
local asMouseHud_mt = Class(asMouseHud);

-- Initialize the Mouse Pointer
function asMouseHud:init() 
	self.oldMouseWrap = wrapMousePosition;	
	--asMouseHud:setEnabled(false);
	self.isDown = false;
end 

-- Set the mouse position
function asMouseHud:setPosition(x,y)
	self.posX = x;
	self.posY = y;
end 

-- Enable/Disable the mouse pointer
function asMouseHud:setEnabled(eb)
	self.enabled = eb;
	
	if self.enabled then 
		g_currentMission.isPlayerFrozen = true;
		wrapMousePosition = function(x,y)
			
		end;
	else 
		g_currentMission.isPlayerFrozen = false;
		wrapMousePosition = self.oldMouseWrap;
	end 
	
	InputBinding.setShowMouseCursor(eb);
end

-- Render the mouse 

function asMouseHud:mouseEvent(posX, posY, isDown, isUp, button)
	-- Track the mouse position
	if self.enabled then
		asMouseHud:setPosition(posX, posY);
		self.isDown = isDown;
	end
end

function asMouseHud:isMouseDown() 
	return self.isDown;
end 

function asMouseHud:isInsideOf(ovX, ovY, ovW, ovH) 
	if self.posX ~= nil and self.posY ~= nil then 
		if self.posX > ovX and self.posX < ovX+ovW and self.posY > ovY and self.posY < ovY+ovH then
			return true;
		else 
			return false;
		end 
	else 
		return false;
	end
end 

function asMouseHud:deleteMap()	
end;

function asMouseHud:update(dt)
end;

function asMouseHud:loadMap(name)
end;

function asMouseHud:draw()		
end;

function asMouseHud:keyEvent(unicode, sym, modifier, isDown)
end;

addModEventListener(asMouseHud);