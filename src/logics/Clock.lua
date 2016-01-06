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
asClock = {}

function asClock:init()
	self.lastHour = 0;
	self.newDayDispatched = false;
	self.regsEvents = {}
end

function asClock:update(env)
	self.lastHour = math.floor(env.dayTime / (1000 * 60 * 60));
	
	if self.lastHour >= 0 and self.lastHour <= 1 and self.newDayDispatched == false then		
		self.newDayDispatched = true;
		asClock:dispatchNewDay();
	end 
	
	if self.lastHour > 1 and self.lastHour <= 23 and self.newDayDispatched then
		self.newDayDispatched = false;
	end 
end

function asClock:dispatchNewDay()
	for key, event in pairs(self.regsEvents) do
		event();
	end 
end

function asClock:registerNewDayEvent(eventName, callback)
	self.regsEvents[eventName] = callback;
end 