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
AgroMessages.SpMsgCount = 3
	
function AgroMessages:show(reward, spName)
	local msgTitle = 'AgroSponsors'
	local msgTxt = ''
	
	local rndIndex = math.random(1, AgroMessages.SpMsgCount);
	local curIndex = 0;
	
	for curIndex=1,AgroMessages.SpMsgCount do
		if rndIndex == curIndex then
			local key = 'AGROSPONSOR_SP' .. curIndex;			
			msgTxt =  as.utils.getText(key);
			break;				
		end
	end;
	
	msgTxt = msgTxt:format(g_i18n:formatMoney(reward));
	msgTxt = string.gsub(msgTxt, '/NAME', spName);
	
	g_currentMission.inGameMessage:showMessage(msgTitle, msgTxt, 15000, false);
end 