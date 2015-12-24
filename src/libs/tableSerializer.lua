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
do
   -- declare local variables
   --// exportstring( string )
   --// returns a "Lua" portable version of the string
   local function exportstring( s )
      return string.format("%q", s)
   end

   --// The Serialize Function
   function table.serialize(  tbl )
      local charS,charE = "   ","\n"
	  local finalString = "";

      -- initiate variables for save procedure
      local tables,lookup = { tbl },{ [tbl] = 1 }
      finalString = finalString .. ( "return {"..charE )

      for idx,t in ipairs( tables ) do
         finalString = finalString .. ( "-- Table: {"..idx.."}"..charE )
         finalString = finalString ..( "{"..charE )
         local thandled = {}

         for i,v in ipairs( t ) do
            thandled[i] = true
            local stype = type( v )
            -- only handle value
            if stype == "table" then
               if not lookup[v] then
                  table.insert( tables, v )
                  lookup[v] = #tables
               end
               finalString = finalString .. ( charS.."{"..lookup[v].."},"..charE )
            elseif stype == "string" then
               finalString = finalString .. (  charS..exportstring( v )..","..charE )
            elseif stype == "number" then
               finalString = finalString .. (  charS..tostring( v )..","..charE )
            end
         end

         for i,v in pairs( t ) do
            -- escape handled values
            if (not thandled[i]) then
            
               local str = ""
               local stype = type( i )
               -- handle index
               if stype == "table" then
                  if not lookup[i] then
                     table.insert( tables,i )
                     lookup[i] = #tables
                  end
                  str = charS.."[{"..lookup[i].."}]="
               elseif stype == "string" then
                  str = charS.."["..exportstring( i ).."]="
               elseif stype == "number" then
                  str = charS.."["..tostring( i ).."]="
               end
            
               if str ~= "" then
                  stype = type( v )
                  -- handle value
                  if stype == "table" then
                     if not lookup[v] then
                        table.insert( tables,v )
                        lookup[v] = #tables
                     end
                     finalString = finalString .. ( str.."{"..lookup[v].."},"..charE )
                  elseif stype == "string" then
                     finalString = finalString ..( str..exportstring( v )..","..charE )
                  elseif stype == "number" then
                     finalString = finalString .. ( str..tostring( v )..","..charE )
                  end
               end
            end
         end
         finalString = finalString .. ( "},"..charE )
      end
      finalString = finalString .. ( "}" )
     
	  return finalString;
   end
   
   --// The Deserialize Function
   function table.deserialize( sdata )
      local ftables,err = loadstring( sdata )
      if err then return _,err end
      local tables = ftables()
      for idx = 1,#tables do
         local tolinki = {}
         for i,v in pairs( tables[idx] ) do
            if type( v ) == "table" then
               tables[idx][i] = tables[v[1]]
            end
            if type( i ) == "table" and tables[i[1]] then
               table.insert( tolinki,{ i,tables[i[1]] } )
            end
         end
         -- link indices
         for _,v in ipairs( tolinki ) do
            tables[idx][v[2]],tables[idx][v[1]] =  tables[idx][v[1]],nil
         end
      end
      return tables[1]
   end
-- close do
end

-- ChillCode