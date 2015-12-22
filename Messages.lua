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
AgroMessages = {}
AgroMessages.locales = {}
AgroMessages.SpMsgCount = 0
	
function AgroMessages:load() 
	print('[AgroSponsor] Loading messages')
	AgroMessages.locales = AgroMessages.copyTexts(g_i18n.texts, true);
	
	for k,v in pairs(AgroMessages.locales) do
		if string.find(k,'AGROSPONSOR_SP') then
			AgroMessages.SpMsgCount = AgroMessages.SpMsgCount + 1;
		end 
	end;
end

function AgroMessages:copyTexts(tab, recursive)
	local result = {};
	for k,v in pairs(tab) do
		if string.find(k,'AGROSPONSOR') then
			if recursive and type(v) == 'table' then
				result[k] = self.copyTexts(v, recursive);
			else
				result[k] = v;
			end;
		end 
	end;
	return result;
end 

function AgroMessages:show(reward)
	local msgTitle = 'AgroSponsors'
	local msgTxt = ''
	
	local rndIndex = math.random(0, AgroMessages.SpMsgCount - 1);
	local curIndex = 0;
	for k,v in pairs(AgroMessages.locales) do
		if string.find(k,'AGROSPONSOR_SP') then
			curIndex = curIndex + 1
			if rndIndex == curIndex then
				msgTxt = AgroMessages.locales[k];
				break;				
			end
		end 
	end;
	
	msgTxt = msgTxt:format(g_i18n:formatMoney(reward));
	
	g_currentMission.inGameMessage:showMessage(msgTitle, msgTxt, 15000, false);
end 