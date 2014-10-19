--
-- Pet Party
-- Copyright 2014 James Lammlein
--
-- This file is part of Pet Party.
--
-- Pet Party is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- any later version.
--
-- Pet Party is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with Pet Party.  If not, see <http://www.gnu.org/licenses/>.
--

function PetParty.OnDragStartMainFrame()
    PetParty_MainFrame:StartMoving();
    return;
end

function PetParty.OnDragStopMainFrame()
    PetParty_MainFrame:StopMovingOrSizing();
    return;
end

function PetParty.OnLoadMainFrame()
    PetParty_MainFrame:RegisterForDrag("LeftButton");
    return;
end

function PetParty.OnShowMainFrame()
    PetParty_MainFrame_Title_Font_String:SetText(PetParty.L["Pet Party"]);
    return;
end
