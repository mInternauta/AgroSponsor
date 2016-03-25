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

ASRewardEvent = {};
ASRewardEvent_mt = Class(ASRewardEvent, Event);

InitEventClass(ASRewardEvent, "ASRewardEvent");

function ASRewardEvent:readStream(streamId, connection)
  self.money_amount = streamReadInt32(streamId);
end;

function ASRewardEvent:writeStream(streamId, connection)
  streamWriteInt32(streamId, self.money_amount);
end;

function ASRewardEvent:new(money_amount)
  local self = ASRewardEvent:emptyNew()
  self.money_amount = money_amount;
  return self;
end;

function ASRewardEvent:emptyNew()
  local self = Event:new(ASRewardEvent_mt);
  self.className="ASRewardEvent";
  return self;
end;

function ASRewardEvent:run(connection)
  if not connection:getIsServer() then
      g_currentMission:addSharedMoney(self.money_amount, 'others');
  end;
end;