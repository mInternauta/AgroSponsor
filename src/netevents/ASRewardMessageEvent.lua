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

ASRewardMessageEvent = {};
ASRewardMessageEvent_mt = Class(ASRewardMessageEvent, Event);

InitEventClass(ASRewardMessageEvent, "ASRewardMessageEvent");

function ASRewardMessageEvent:readStream(streamId, connection)
  self.data = streamReadString(streamId);
end;

function ASRewardMessageEvent:writeStream(streamId, connection)
  streamWriteString(streamId, self.data);
end;

function ASRewardMessageEvent:new(money, sptitle)
  local self = ASRewardMessageEvent:emptyNew()
  self.data = tostring(money) .. "-" .. sptitle;
  return self;
end;

function ASRewardMessageEvent:emptyNew()
  local self = Event:new(ASRewardEvent_mt);
  self.className="ASRewardMessageEvent";
  return self;
end;

function ASRewardMessageEvent:run(connection)
  if not connection:getIsServer() then
      local money_amount;
      local spTitle;
      
      local splited = split(self.data, "-");
      spTitle = splited[2];
      money_amount = tonumber(splited[1]);
      
      AgroMessages:showReward(money_amount, spTitle);
  end;
end;