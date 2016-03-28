-- Copyright (C) 2016 mInternauta

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

ASRemoveRentEvent = {};
ASRemoveRentEvent_mt = Class(ASRemoveRentEvent, Event);

InitEventClass(ASRemoveRentEvent, "ASRemoveRentEvent");

function ASRemoveRentEvent:readStream(streamId, connection)
  self.rentId = streamReadInt32(streamId);
end;

function ASRemoveRentEvent:writeStream(streamId, connection)
  streamWriteInt32(streamId, self.rentId);
end;

function ASRemoveRentEvent:new(rentId)
  local self = ASRemoveRentEvent:emptyNew()
  self.rentId = rentId;
  return self;
end;

function ASRemoveRentEvent:emptyNew()
  local self = Event:new(ASRemoveRentEvent_mt);
  self.className="ASRemoveRentEvent";
  return self;
end;

function ASRemoveRentEvent:run(connection)
  if not connection:getIsServer() then
      g_currentMission:removeVehicle(self.rentId, true);
  end;
end;