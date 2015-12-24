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

asDialogs = {}

-- Show a YesNo Dialog 
-- Title = Title of the dialog
-- Text = Text of the dialog
-- callbackFn(bool) = Callback for the dialog 
function asDialogs:showYesNo(title, text, callbackFn)
	local yesNoDialogue = g_gui:showGui('YesNoDialog');
	yesNoDialogue.target.titleElement:setText(title);
	yesNoDialogue.target:setText(text);
	yesNoDialogue.target:setCallbacks(callbackFn, self);
end;