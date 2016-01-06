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
as = {}
as.utils = {}
as.tables = {}

function as.tables.len(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function as.tables.getKeyInIndex(index, tab)
	local indx = 0;
	local keyname = nil;
	
	for k,v in pairs(tab) do 
		if indx == index then 
			keyname = k;
			break;
		else 
			indx = indx + 1;
		end 
    end
	
	return keyname;
end 

function as.utils.getText(key)
	local text = g_i18n:getText(key);
	
	-- Format CR LF Chars
	text = string.gsub(text, '/CR', '\r');
	text = string.gsub(text, '/LF', '\n');
	
	return text;
end 

function as.utils.toMoneyString(number)
	return ('%s'):format(g_i18n:formatMoney(number))
end

function as.utils.getPxToNormalConstant(widthPx, heightPx)
	return widthPx/g_screenWidth, heightPx/g_screenHeight;
end

function as.utils.printDebug(info)
	print('[AgroSponsor] [DEBUG] ' .. info);
end

function as.utils.randomID()
	local random = math.random
	local function uuid()
		local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
		return string.gsub(template, '[xy]', function (c)
			local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
			return string.format('%x', v)
		end)
	end
	
	return uuid();
end 

function as.utils.print_r( t )  
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end